#!/usr/bin/env python3
"""Cursor preToolUse hook: rewrite git commit commands to strip disallowed trailers.

Policies match ``check_git_trailer_policy`` in ``validate-git-shell.py`` (TRAILER_RULES).
Keep the regex rules in sync if either file changes.
"""

from __future__ import annotations

import json
import shlex
import sys

from hook_lib.commands import ParsedCommand
from hook_lib.git import TRAILER_SUBSTR, TRAILER_LINE_START
from hook_lib.io import (
    PreToolUseInput,
    PreToolUseOutput,
    RewriteOutput,
    PassthroughOutput,
)


def main() -> None:
    result = run(sys.stdin.read())
    print(json.dumps(result.output), flush=True)
    raise SystemExit(result.exit_code)


def run(stdin_text: str) -> PreToolUseOutput:
    r"""Parse hook JSON from *stdin_text* and return passthrough or rewrite.

    On invalid input the hook passes through (never blocks).

        >>> run("not json").output
        {}
        >>> run("[]").output
        {}
        >>> run('{}').output
        {}
        >>> run('{"tool_input": {}}').output
        {}
        >>> run('{"tool_input": {"command": ""}}').output
        {}

    Non-git commands pass through unchanged.

        >>> run('{"tool_input": {"command": "echo ok"}}').output
        {}

    Git commands without trailers pass through.

        >>> run('{"tool_input": {"command": "git status"}}').output
        {}
        >>> run('{"tool_input": {"command": "git commit -m \\"fix bug\\""}}').output
        {}

    Commands with trailers are rewritten.

        >>> r = run('{"tool_input": {"command": "git commit --trailer \\"Key: v\\" -m \\"hi\\""}}')
        >>> r.output['permission']
        'allow'
        >>> '--trailer' in r.output['updated_input']['command']
        False
        >>> r = run('{"tool_input": {"command": "git commit -m \\"x\\" -m \\"Co-authored-by: a\\""}}')
        >>> r.output['permission']
        'allow'
        >>> 'Co-authored-by' in r.output['updated_input']['command']
        False
    """
    try:
        hook_input = PreToolUseInput.loads(stdin_text)
    except Exception:
        return PreToolUseOutput(output=PassthroughOutput())
    command = hook_input.command
    if command is None:
        return PreToolUseOutput(output=PassthroughOutput())
    return evaluate_command(command)


def evaluate_command(command: str) -> PreToolUseOutput:
    """Rewrite *command* to strip trailers, or passthrough if already clean."""
    new_command = rewrite_command(command)
    if new_command == command:
        return PreToolUseOutput(output=PassthroughOutput())
    return PreToolUseOutput(
        output=RewriteOutput(
            permission="allow",
            updated_input={"command": new_command},
        ),
    )


def rewrite_command(command: str) -> str:
    r"""Return *command* with disallowed ``git commit`` trailer usage removed.

    >>> rewrite_command('git status')
    'git status'

    >>> rewrite_command('git commit --trailer "Key: value" -m "feature: add new feature"')
    "git commit -m 'feature: add new feature'"

    >>> rewrite_command('git commit -m "fix(ui): improve button styles" -m "Co-authored-by: a <a@b.co>"')
    "git commit -m 'fix(ui): improve button styles'"

    >>> rewrite_command('git commit -m "add cursor support" -m "Made-with: Cursor"')
    "git commit -m 'add cursor support'"
    """
    cmd = ParsedCommand.parse(command)
    new_cmd = cmd.map_segments(rewrite_shell_segment)
    if new_cmd == cmd:
        return command
    return str(new_cmd)


def rewrite_shell_segment(segment: str) -> str:
    """Rewrite a single shell segment (a simple command with no operators)."""
    try:
        argv = shlex.split(segment, posix=True)
    except ValueError:
        return segment
    if not argv:
        return segment
    new_argv = rewrite_one_argv_segment(argv)
    if new_argv == argv:
        return segment
    return shlex.join(new_argv)


def rewrite_one_argv_segment(argv: list[str]) -> list[str]:
    """Strip trailer args from a single ``git ... commit`` invocation."""
    cidx = find_git_commit_index(argv)
    if cidx is None:
        return argv
    head = argv[: cidx + 1]
    tail = argv[cidx + 1 :]
    return head + filter_commit_tail(tail)


def find_git_commit_index(argv: list[str]) -> int | None:
    """Return index of ``commit`` token for a ``git ... commit`` invocation.

    >>> find_git_commit_index(["git", "commit", "-m", "hi"])
    1
    >>> find_git_commit_index(["git", "-C", "/tmp", "commit", "-m", "x"])
    3
    >>> find_git_commit_index(["git", "status"]) is None
    True
    >>> find_git_commit_index(["echo", "commit"]) is None
    True
    """
    for i, tok in enumerate(argv):
        if tok != "git":
            continue
        for j in range(i + 1, len(argv)):
            if argv[j] == "commit":
                return j
    return None


def filter_commit_tail(tail: list[str]) -> list[str]:
    r"""Drop ``--trailer`` and clean ``-m``/``--message`` pairs that violate trailer policy.

    >>> filter_commit_tail(["--trailer", "Key: value", "-m", '"hi"'])
    ['-m', '"hi"']
    >>> filter_commit_tail(["--trailer=Key: value", "-m", '"hi"'])
    ['-m', '"hi"']
    >>> filter_commit_tail(["-m", '"Co-authored-by: A <a@b>"'])
    []
    >>> filter_commit_tail(["-m", "Fix bug", "-m", "Co-authored-by: A <a@b>"])
    ['-m', 'Fix bug']
    >>> filter_commit_tail(['"--message=Co-authored-by: A <a@b>"'])
    []
    >>> filter_commit_tail(["--message=Fix bug\nCo-authored-by: A <a@b>"])
    ['--message=Fix bug']
    >>> filter_commit_tail(["-m", "Fix bug"])
    ['-m', 'Fix bug']
    """
    out: list[str] = []
    i = 0
    while i < len(tail):
        t = tail[i]
        # Strip surrounding double-quotes for flag recognition: some argv
        # representations (e.g. non-POSIX) keep literal quote chars on tokens.
        t_inner = t[1:-1] if len(t) >= 2 and t[0] == '"' and t[-1] == '"' else t

        if t_inner.startswith("--trailer"):
            i += 1 if t_inner != "--trailer" else 2
            continue

        if t_inner in ("-m", "--message"):
            if i + 1 >= len(tail):
                out.append(t)
                i += 1
                continue
            cleaned = clean_message_value(tail[i + 1])
            if cleaned is not None:
                out.extend([t, cleaned])
            i += 2
            continue

        if t_inner.startswith("-m") and len(t_inner) > 2 and t_inner[2] != "=":
            cleaned = clean_message_value(t_inner[2:])
            if cleaned is not None:
                out.append(f"-m{cleaned}")
            i += 1
            continue

        if t_inner.startswith("--message="):
            cleaned = clean_message_value(t_inner.split("=", 1)[1])
            if cleaned is not None:
                out.append(f"--message={cleaned}")
            i += 1
            continue

        out.append(t)
        i += 1
    return out


def clean_message_value(raw: str) -> str | None:
    """Return cleaned message text, or ``None`` if nothing meaningful remains.

    Surrounding double-quotes are stripped before analysis so that quoted
    tokens (from non-POSIX argv representations) are handled correctly;
    the original *raw* value is returned when no cleaning is needed.

    >>> clean_message_value("Fix bug")
    'Fix bug'
    >>> clean_message_value("Co-authored-by: A <a@b>") is None
    True
    >>> clean_message_value("Fix bug\\nCo-authored-by: A <a@b>")
    'Fix bug'
    >>> clean_message_value('"Co-authored-by: A <a@b>"') is None
    True
    >>> clean_message_value('"hi"')
    '"hi"'
    """
    inner = raw[1:-1] if len(raw) >= 2 and raw[0] == '"' and raw[-1] == '"' else raw
    if not TRAILER_SUBSTR.search(inner):
        return raw
    return strip_trailer_message_body(inner)


def strip_trailer_message_body(msg: str) -> str | None:
    """Remove trailer footers from a commit message body. ``None`` if nothing left.

    Drops whole lines that are standard trailer footers (``Co-authored-by:``,
    etc.). Removes inline ``Key:`` fragments from remaining lines.

        >>> strip_trailer_message_body("Co-authored-by: A <a@b.co>") is None
        True
        >>> strip_trailer_message_body("Made-with: Cursor") is None
        True
        >>> strip_trailer_message_body("Fix bug\\nCo-authored-by: A <a@b.co>")
        'Fix bug'
        >>> strip_trailer_message_body("Fix bug")
        'Fix bug'
        >>> strip_trailer_message_body("First line\\n\\nSigned-off-by: Bot")
        'First line'
        >>> strip_trailer_message_body("") is None
        True
    """
    kept: list[str] = []
    for ln in msg.splitlines():
        s = ln.strip()
        if not s:
            continue
        if TRAILER_LINE_START.match(s):
            continue
        line = _remove_all_trailer_substrings(ln)
        if line:
            kept.append(line)
    text = "\n".join(kept)
    if not text.strip():
        return None
    text = _remove_all_trailer_substrings(text)
    return text or None


def _remove_all_trailer_substrings(text: str) -> str:
    """Repeatedly strip trailer substrings until stable, then trim whitespace."""
    prev = None
    while prev != text:
        prev = text
        text = TRAILER_SUBSTR.sub("", text)
    return text.strip()


if __name__ == "__main__":
    main()
