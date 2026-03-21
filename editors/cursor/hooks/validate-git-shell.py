#!/usr/bin/env python3
"""Cursor beforeShellExecution hook: git trailer and destructive push policy."""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from typing import Any, Literal, TypedDict


@dataclass(frozen=True, slots=True)
class BeforeShellExecutionInput:
    """Subset of stdin JSON

    Cursor may send additional keys.
    See https://cursor.com/docs/hooks for more information.
    """

    command: str
    cwd: str | None
    sandbox: bool | None

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
        >>> run("not json").exit_code
        0
        >>> run("{}").output["permission"]
        'allow'
        >>> run('{"command": "echo ok"}').output["permission"]
        'allow'
        >>> r = run('{"command": "git push --force"}')
        >>> r.exit_code
        2
        >>> r.output["permission"]
        'deny'
        >>> r.output["user_message"]
        'Blocked: git push policy.'
        >>> r = run('{"command": "git commit --trailer Key: value"}')
        >>> r.exit_code
        2
        >>> r.output["user_message"]
        'Blocked: git trailer policy.'

    Run tests with the stdlib (no extra packages), from the directory that
    contains this script::

        python3 validate-git-shell --doctest

    Exit status is 0 if all examples pass, 1 otherwise.
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
        data = json.loads(stdin_text)
    except json.JSONDecodeError:
        return None
    if not isinstance(data, dict):
        return None
    return BeforeShellExecutionInput(**data)


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
    for pattern, message in TRAILER_RULES:
        if pattern.search(segment):
            return message
    return None


def git_push_violation(segment: str) -> str | None:
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
