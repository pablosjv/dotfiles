#!/usr/bin/env python3
"""Cursor beforeShellExecution hook: git trailer and destructive push policy."""

from __future__ import annotations

import json
import re
import sys
from typing import Literal, NamedTuple

from hook_lib.commands import ParsedCommand
from hook_lib.git import TRAILER_RULES, PUSH_TAIL_RULES
from hook_lib.io import (
    BeforeShellExecutionInput,
    BeforeShellExecutionOutput,
    AllowOutput,
    DenyOutput,
)


PolicyKind = Literal["trailer", "push"]


class PolicyPass(NamedTuple):
    check: Literal[True] = True
    message: str | None = None
    policy: Literal[None] = None


class PolicyBreach(NamedTuple):
    message: str
    policy: PolicyKind
    check: Literal[False] = False


PolicyResult = PolicyPass | PolicyBreach


USER_DENY_BY_POLICY: dict[PolicyKind, str] = {
    "trailer": "Blocked: git trailer policy.",
    "push": "Blocked: git push policy.",
}


def main() -> None:
    result = run(sys.stdin.read())
    print(json.dumps(result.output), flush=True)
    raise SystemExit(result.exit_code)


def run(stdin_text: str) -> BeforeShellExecutionOutput:
    r"""Parse hook JSON from ``stdin_text`` and return allow or deny.

    When the hook input is invalid, it denies and returns a clear error message.

        >>> result = run("not json")
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2
        >>> result.output['user_message']
        'Hook input could not be parsed: Invalid JSON: not json'
        >>> result = run("{}")
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2
        >>> result.output['user_message']  # doctest: +ELLIPSIS
        "Hook input could not be parsed: ...missing 1 required positional argument: 'command'"

    If there is no command, it allows.

        >>> run('{"command": ""}')
        BeforeShellExecutionOutput(output={'permission': 'allow'}, exit_code=0)

    The hook only matches git commands, for the rest it allows.

        >>> run('{"command": "echo ok"}')
        BeforeShellExecutionOutput(output={'permission': 'allow'}, exit_code=0)
        >>> run('{"command": "less /etc/hosts"}')
        BeforeShellExecutionOutput(output={'permission': 'allow'}, exit_code=0)
        >>> run('{"command": "gitkraken open"}')
        BeforeShellExecutionOutput(output={'permission': 'allow'}, exit_code=0)

    It allows basic git commands if they do not violate the policies.

        >>> run('{"command": "git status"}')
        BeforeShellExecutionOutput(output={'permission': 'allow'}, exit_code=0)
        >>> run('{"command": "git add ."}')
        BeforeShellExecutionOutput(output={'permission': 'allow'}, exit_code=0)
        >>> run('{"command": "git commit -m \\"x\\""}')
        BeforeShellExecutionOutput(output={'permission': 'allow'}, exit_code=0)

    The hook denies if it violates the trailer policy.

        >>> result = run('{"command": "git commit -m \\"x\\" -m \\"Co-authored-by: Cursor\\""}')
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2
        >>> result.output['user_message']
        'Blocked: git trailer policy.'

    The hook denies if it violates the push policy.

        >>> result = run('{"command": "git push --force"}')
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2
        >>> result.output['user_message']
        'Blocked: git push policy.'

    Git command might be invoked doing a cd or it might be rewritten by other hooks like rtk.
    This should not affect the policy evaluation.

        >>> result = run('{"command": "cd /tmp && git commit -m \\"x\\" -m \\"Co-authored-by: Cursor\\""}')
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2
        >>> result.output['user_message']
        'Blocked: git trailer policy.'
        >>> result = run('{"command": "HUSKY=0 rtk git commit -m \\"x\\" -m \\"Co-authored-by: Cursor\\""}')
        >>> result.output['permission']
        'deny'
        >>> result.exit_code
        2
        >>> result.output['user_message']
        'Blocked: git trailer policy.'

    """
    try:
        hookInput = BeforeShellExecutionInput.loads(stdin_text)
    except Exception as e:
        return BeforeShellExecutionOutput(
            output=DenyOutput(
                permission="deny",
                user_message=f"Hook input could not be parsed: {e}",
                agent_message="Hook input could not be parsed. Something is wrong with the user hook configuration or scripts.",
            ),
            exit_code=2,
        )
    command = hookInput.command_cleaned
    if command is None:
        return BeforeShellExecutionOutput(
            output=AllowOutput(permission="allow"), exit_code=0
        )
    return evaluate_command(command)


def evaluate_command(command: str) -> BeforeShellExecutionOutput:
    for segment in ParsedCommand.parse(command).segments:
        if violation := check_git_violations(segment):
            return BeforeShellExecutionOutput(
                output=get_deny_output(violation=violation),
                exit_code=2,
            )
    return BeforeShellExecutionOutput(
        output=AllowOutput(permission="allow"), exit_code=0
    )


def check_git_violations(segment: str) -> PolicyBreach | None:
    trailer_result = check_git_trailer_policy(segment)
    if not trailer_result.check:
        return trailer_result
    push_result = check_git_push_policy(segment)
    if not push_result.check:
        return push_result
    return None


def get_deny_output(violation: PolicyBreach) -> DenyOutput:
    return DenyOutput(
        permission="deny",
        user_message=USER_DENY_BY_POLICY[violation.policy],
        agent_message=violation.message,
    )


def check_git_trailer_policy(segment: str) -> PolicyResult:
    """Return a denial message if ``segment`` violates trailer rules, else None.

    Examples:
        >>> r = check_git_trailer_policy("echo hello")
        >>> r.check
        True
        >>> r = check_git_trailer_policy("git status")
        >>> r.check
        True
        >>> r = check_git_trailer_policy('git commit --trailer "Key: value"')
        >>> r.check
        False
        >>> r = check_git_trailer_policy(
        ...     'git commit -m "x" -m "Co-authored-by: a <a@b.co>"'
        ... )
        >>> r.check
        False
        >>> r = check_git_trailer_policy(
        ...     'git commit -m "x" -m "Made-with: Cursor"'
        ... )
        >>> r.check
        False
    """
    for pattern, message in TRAILER_RULES:
        if pattern.search(segment):
            return PolicyBreach(policy="trailer", message=message)
    return PolicyPass(message="No pattern found")


def check_git_push_policy(segment: str) -> PolicyResult:
    """Return a denial message if ``segment`` is a destructive ``git push``, else None.

    Only the argument tail after ``git ... push`` is checked, so ``git clean -f``
    alone does not match push rules.

    Examples:
        >>> r = check_git_push_policy("git status")
        >>> r.check
        True
        >>> r = check_git_push_policy("git push origin main")
        >>> r.check
        True
        >>> r = check_git_push_policy("git push --force")
        >>> r.check
        False
        >>> r = check_git_push_policy("git push --force")
        >>> r.check
        False
        >>> "force" in (r.message or "").lower()
        True
        >>> r = check_git_push_policy("git push --force-with-lease")
        >>> r.check
        True
        >>> r = check_git_push_policy("git clean -f")
        >>> r.check
        True
        >>> r = check_git_push_policy("git -C /repo push --mirror")
        >>> r.check
        False
        >>> "mirror" in (r.message or "").lower()
        True
        >>> r = check_git_push_policy("git push origin +refs/heads/main")
        >>> r.check
        False
        >>> r = check_git_push_policy("git clean -f && git push --force")
        >>> r.check
        False
        >>> "force" in r.message.lower()
        True
    """
    push_pattern = re.compile(
        r"\bgit(?:\s+\S+)*\s+push\b(.*)$", re.IGNORECASE | re.DOTALL
    )
    push_match = push_pattern.search(segment)
    if not push_match:
        return PolicyPass(message="No push command found")
    tail = push_match.group(1) or ""
    for pattern, message in PUSH_TAIL_RULES:
        if pattern.search(tail):
            return PolicyBreach(policy="push", message=message)
    return PolicyPass(message="Push command does not violate the policy")


if __name__ == "__main__":
    main()
