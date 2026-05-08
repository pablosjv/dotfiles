"""Manipulate shell commands."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Callable

# Captures &&, ||, |, and ; as operators (|| before | to avoid short-circuit).
_OPERATOR_RE = re.compile(r"\s*(&&|\|\||\|(?!\|)|;)\s*")


@dataclass
class ParsedCommand:
    """A shell command decomposed into simple segments and connecting operators.

    ``segments[i]`` is connected to ``segments[i+1]`` by ``operators[i]``, so
    ``len(operators) == len(segments) - 1`` always holds.
    """

    segments: list[str]
    operators: list[str]

    @classmethod
    def parse(cls, command: str) -> ParsedCommand:
        """Parse *command* into segments separated by ``&&``, ``||``, ``|``, or ``;``.

        >>> pc = ParsedCommand.parse("git status")
        >>> pc.segments
        ['git status']
        >>> pc.operators
        []

        >>> pc = ParsedCommand.parse("cd /tmp && git commit -m 'x'")
        >>> pc.segments
        ['cd /tmp', "git commit -m 'x'"]
        >>> pc.operators
        ['&&']

        >>> pc = ParsedCommand.parse("a; b || c && d")
        >>> pc.segments
        ['a', 'b', 'c', 'd']
        >>> pc.operators
        [';', '||', '&&']

        >>> pc = ParsedCommand.parse("a | b | c")
        >>> pc.segments
        ['a', 'b', 'c']
        >>> pc.operators
        ['|', '|']
        """
        parts = _OPERATOR_RE.split(command)
        segments = [parts[i].strip() for i in range(0, len(parts), 2)]
        operators = [parts[i] for i in range(1, len(parts), 2)]
        return cls(segments=segments, operators=operators)

    def __str__(self) -> str:
        """Reconstruct the command string from segments and operators.

        Whitespace around operators is normalised to a single space on each side.

        >>> str(ParsedCommand.parse("git status"))
        'git status'

        >>> str(ParsedCommand.parse("cd /tmp && git commit -m 'x'"))
        "cd /tmp && git commit -m 'x'"

        >>> str(ParsedCommand.parse("a; b || c && d"))
        'a ; b || c && d'

        >>> str(ParsedCommand.parse("a | b | c"))
        'a | b | c'
        """
        if not self.segments:
            return ""
        result = self.segments[0]
        for op, seg in zip(self.operators, self.segments[1:]):
            result += f" {op} {seg}"
        return result

    def map_segments(self, fn: Callable[[str], str]) -> ParsedCommand:
        """Return a new ``ParsedCommand`` with *fn* applied to each segment.

        Operators are preserved unchanged.

        >>> pc = ParsedCommand.parse("git status && git commit -m 'x'")
        >>> str(pc.map_segments(str.upper))
        "GIT STATUS && GIT COMMIT -M 'X'"
        """
        return ParsedCommand(
            segments=[fn(s) for s in self.segments],
            operators=self.operators,
        )


def remove_parameter(argv: list[str], param: str) -> list[str]:
    """Remove all occurrences of *param* (and its value, if any) from *argv*.

    Handles three forms:
    - Boolean flags: ``--force``
    - ``=``-joined options: ``--trailer="Made by Cursor"``
    - Space-separated options: ``--trailer`` ``"Made by Cursor"``

    *param* should be the bare flag name without a value, e.g. ``"--force"``
    or ``"--trailer"``.

    >>> remove_parameter(["git", "commit", "--force", "-m", "msg"], "--force")
    ['git', 'commit', '-m', 'msg']

    >>> remove_parameter(["git", "commit", '--trailer="Co-authored-by: x"', "-m", "msg"], "--trailer")
    ['git', 'commit', '-m', 'msg']

    >>> remove_parameter(["git", "commit", "--trailer", "Co-authored-by: x", "-m", "msg"], "--trailer")
    ['git', 'commit', '-m', 'msg']

    >>> remove_parameter(["git", "commit", "--trailer=a", "--trailer=b", "-m", "msg"], "--trailer")
    ['git', 'commit', '-m', 'msg']

    >>> remove_parameter(["git", "commit", "-m", "msg"], "--trailer")
    ['git', 'commit', '-m', 'msg']

    >>> remove_parameter(["git", "commit", "--trailer", "a", "--trailer", "b"], "--trailer")
    ['git', 'commit']
    """
    result: list[str] = []
    prefix = param + "="
    i = 0
    while i < len(argv):
        token = argv[i]
        if token == param:
            i += 1
            # Space-separated form: also consume the next token if it looks
            # like a value (i.e. does not start with "-").
            if i < len(argv) and not argv[i].startswith("-"):
                i += 1
        elif token.startswith(prefix):
            # =-joined form: skip just this token.
            i += 1
        else:
            result.append(token)
            i += 1
    return result
