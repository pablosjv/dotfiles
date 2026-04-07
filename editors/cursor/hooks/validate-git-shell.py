#!/usr/bin/env python3
"""Cursor beforeShellExecution hook: git trailer and destructive push policy."""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass, field
from typing import Any, Literal, TypedDict


@dataclass(frozen=True, slots=True)
class BeforeShellExecutionInput:
    """beforeShellExecution hook stdin payload.

    Hook-specific fields are listed first; Cursor also injects a set of base
    fields into every hook call (see https://cursor.com/docs/hooks#common-schema).
    """

    # Hook-specific fields
    command: str
    cwd: str | None = None
    sandbox: bool | None = None

    # Cursor base fields (present on every hook call)
    conversation_id: str | None = None
    generation_id: str | None = None
    model: str | None = None
    hook_event_name: str | None = None
    cursor_version: str | None = None
    workspace_roots: list[str] = field(default_factory=list)
    user_email: str | None = None
    transcript_path: str | None = None

    @property
    def command_cleaned(self) -> str | None:
        command = self.command.strip()
        if not command:
            return None
        return command


@dataclass(frozen=True, slots=True)
class PolicyResult:
    """Outcome of evaluating one shell command string."""

    output: AllowOutput | DenyOutput
    exit_code: Literal[0, 2]


class AllowOutput(TypedDict):
    permission: Literal["allow"]


class DenyOutput(TypedDict):
    permission: Literal["deny"]
    user_message: str
    agent_message: str


RegexRule = tuple[re.Pattern[str], str]

PUSH_TAIL_RULES: tuple[RegexRule, ...] = (
    (re.compile(r"(^|\s)--force(\s|$)"), 'git push must not use "--force".'),
    (re.compile(r"(^|\s)-f(\s|$)"), 'git push must not use "-f" (force).'),
    (re.compile(r"(^|\s)--mirror(\s|$)"), 'git push must not use "--mirror".'),
    (re.compile(r"(^|\s)--delete(\s|$)"), 'git push must not use "--delete".'),
    (re.compile(r"\s\+[^\s]+"), "git push must not use a + refspec (force update)."),
)


TRAILER_RULES: tuple[RegexRule, ...] = (
    (
        re.compile(r"(?<![\w-])--trailer(?![\w-])"),
        (
            "Git commands must not use --trailer or other git trailer mechanisms. "
            "Use a plain commit message without trailer footers."
        ),
    ),
    (
        re.compile(
            r"(?is)"
            r"(?=.*\bcommit\b)"
            r"(?=.*(?:Co-authored-by|Signed-off-by|Reviewed-by|Acked-by|Helped-by|Reported-by|Made-with)\s*:)"
        ),
        (
            "Git commit commands must not include git trailer lines (e.g. Co-authored-by, "
            "Signed-off-by, Made-with) in the message."
        ),
    ),
)


PolicyKind = Literal["trailer", "push"]

USER_DENY_BY_POLICY: dict[PolicyKind, str] = {
    "trailer": "Blocked: git trailer policy.",
    "push": "Blocked: git push policy.",
}


@dataclass(frozen=True, slots=True)
class Violation:
    """Which policy fired and the detailed message for the agent."""

    policy: PolicyKind
    agent_message: str


def main() -> None:
    result = run(sys.stdin.read())
    print(json.dumps(result.output), flush=True)
    raise SystemExit(result.exit_code)


def run(stdin_text: str) -> PolicyResult:
    """Parse hook JSON from ``stdin_text`` and return allow or deny.

    Invalid JSON, non-dict payloads, and missing/blank ``command`` fail open
    (allow). Otherwise shell command policy is applied.

    Examples:
        >>> run("not json")
        PolicyResult(output={'permission': 'allow'}, exit_code=0)
        >>> run("{}")
        PolicyResult(output={'permission': 'allow'}, exit_code=0)
        >>> run('{"command": "echo ok"}')
        PolicyResult(output={'permission': 'allow'}, exit_code=0)
        >>> result = run('{"command": "git push --force"}')
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2
        >>> result = run('{"command": "git commit --trailer Key: value"}')
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2

    """
    hookInput = parse_stdin_payload(stdin_text)
    if hookInput is None:
        return PolicyResult(output=AllowOutput(permission="allow"), exit_code=0)
    command = hookInput.command_cleaned
    if command is None:
        return PolicyResult(output=AllowOutput(permission="allow"), exit_code=0)
    return evaluate_command(command)


def parse_stdin_payload(stdin_text: Any) -> BeforeShellExecutionInput | None:
    try:
        data: dict[str, Any] = json.loads(stdin_text)
        hookInput = BeforeShellExecutionInput(**data)
    except json.JSONDecodeError:
        return None
    except TypeError:
        return None
    return hookInput


def evaluate_command(command: str) -> PolicyResult:
    for segment in split_command_segments(command):
        if violation := get_git_violation(segment):
            return PolicyResult(
                output=deny_output(violation.policy, violation.agent_message),
                exit_code=2,
            )
    return PolicyResult(output=AllowOutput(permission="allow"), exit_code=0)


def split_command_segments(command: str) -> list[str]:
    segment_split = re.compile(r"\s*(?:&&|\|\||;)\s*")
    return [s.strip() for s in segment_split.split(command) if s.strip()]


def get_git_violation(segment: str) -> Violation | None:
    if msg := git_trailer_violation(segment):
        return Violation("trailer", msg)
    if msg := git_push_violation(segment):
        return Violation("push", msg)
    return None


def deny_output(policy: PolicyKind, agent_message: str) -> DenyOutput:
    return DenyOutput(
        permission="deny",
        user_message=USER_DENY_BY_POLICY[policy],
        agent_message=agent_message,
    )


def git_trailer_violation(segment: str) -> str | None:
    """Return a denial message if ``segment`` violates trailer rules, else None.

    Examples:
        >>> git_trailer_violation("echo hello") is None
        True
        >>> git_trailer_violation("git status") is None
        True
        >>> git_trailer_violation('git commit --trailer "Key: value"') is not None
        True
        >>> git_trailer_violation(
        ...     'git commit -m "x" -m "Co-authored-by: a <a@b.co>"'
        ... ) is not None
        True
        >>> git_trailer_violation(
        ...     'git commit -m "x" -m "Made-with: Cursor"'
        ... ) is not None
        True
    """
    for pattern, message in TRAILER_RULES:
        if pattern.search(segment):
            return message
    return None


def git_push_violation(segment: str) -> str | None:
    """Return a denial message if ``segment`` is a destructive ``git push``, else None.

    Only the argument tail after ``git ... push`` is checked, so ``git clean -f``
    alone does not match push rules.

    Examples:
        >>> git_push_violation("git status") is None
        True
        >>> git_push_violation("git push origin main") is None
        True
        >>> git_push_violation("git push --force") is not None
        True
        >>> "force" in (git_push_violation("git push --force") or "").lower()
        True
        >>> git_push_violation("git push --force-with-lease") is None
        True
        >>> git_push_violation("git clean -f") is None
        True
        >>> git_push_violation("git -C /repo push --mirror") is not None
        True
        >>> "mirror" in (git_push_violation("git push --mirror") or "").lower()
        True
        >>> git_push_violation("git push origin +refs/heads/main") is not None
        True
        >>> msg = git_push_violation("git clean -f && git push --force")
        >>> msg is not None and "force" in msg.lower()
        True
    """
    push_pattern = re.compile(
        r"\bgit(?:\s+\S+)*\s+push\b(.*)$", re.IGNORECASE | re.DOTALL
    )
    push_match = push_pattern.search(segment)
    if not push_match:
        return None
    tail = push_match.group(1) or ""
    for pattern, message in PUSH_TAIL_RULES:
        if pattern.search(tail):
            return message
    return None


if __name__ == "__main__":
    main()
