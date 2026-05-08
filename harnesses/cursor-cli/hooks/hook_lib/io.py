"""Common types and IO helpers for Cursor hooks.

See https://cursor.com/docs/hooks#common-schema
"""

import json
from dataclasses import dataclass, field, fields
from typing import TypeVar, Any, Self
import json
import shlex
import sys
from dataclasses import dataclass, field
from typing import Any, Literal, TypedDict

_T = TypeVar("_T")


def parse_hook_json(raw_json: str, cls: type[_T]) -> _T:
    """Parse *raw_json* into *cls*, silently dropping unknown fields.

    Raises :exc:`ValueError` on invalid JSON or a non-dict payload.  The
    dataclass constructor is then called with only the known fields; it raises
    ``TypeError`` for any missing required positional arguments, which the
    caller is responsible for handling.

    >>> from dataclasses import dataclass
    >>> @dataclass
    ... class Sample:
    ...     x: int
    ...     y: int = 0
    >>> parse_hook_json('{"x": 1, "z": 99}', Sample)
    Sample(x=1, y=0)
    >>> parse_hook_json('not json', Sample)
    Traceback (most recent call last):
    ...
    ValueError: Invalid JSON: not json
    >>> parse_hook_json('[]', Sample)
    Traceback (most recent call last):
    ...
    ValueError: Invalid JSON: []
    """
    try:
        data = json.loads(raw_json)
    except (json.JSONDecodeError, TypeError):
        raise ValueError(f"Invalid JSON: {raw_json}")
    if not isinstance(data, dict):
        raise ValueError(f"Invalid JSON: {raw_json}")
    valid_fields = {f.name for f in fields(cls)}  # type: ignore[arg-type]
    return cls(**{k: v for k, v in data.items() if k in valid_fields})  # type: ignore[return-value]


@dataclass(frozen=True, slots=True)
class PreToolUseInput:
    """preToolUse hook stdin payload.

    The ``tool_input`` dict carries the tool-specific arguments; for Shell
    calls the key of interest is ``command``.

    Hook-specific fields are listed first; Cursor also injects a set of base
    fields into every hook call (see https://cursor.com/docs/hooks#common-schema).
    """

    tool_input: dict[str, Any]
    tool_name: str | None = None
    model: str | None = None
    hook_event_name: str | None = None
    cursor_version: str | None = None
    conversation_id: str | None = None
    generation_id: str | None = None
    user_email: str | None = None
    transcript_path: str | None = None
    sandbox: bool = False
    workspace_roots: list[str] = field(default_factory=list)

    @classmethod
    def loads(cls, raw_json: str) -> Self:
        """Parse JSON into a :class:`PreToolUseInput`.

        Unknown fields are silently dropped so that new Cursor base fields
        never cause a ``TypeError`` that would make the hook fail open.

        Examples:
            >>> PreToolUseInput.loads('not json')
            Traceback (most recent call last):
            ...
            ValueError: Invalid JSON: not json
            >>> PreToolUseInput.loads('[]')
            Traceback (most recent call last):
            ...
            ValueError: Invalid JSON: []
            >>> PreToolUseInput.loads('{"tool_input": {"command": "echo hi"}}').command
            'echo hi'
            >>> PreToolUseInput.loads('{"tool_input": {"command": "echo"}, "unknown": 1}').command
            'echo'
        """
        return parse_hook_json(raw_json, cls)

    @property
    def command(self) -> str | None:
        """Extract and strip the shell command from ``tool_input``."""
        raw = (self.tool_input or {}).get("command", "")
        stripped = str(raw).strip()
        return stripped or None


@dataclass(frozen=True, slots=True)
class BeforeShellExecutionInput:
    """beforeShellExecution hook stdin payload.

    Hook-specific fields are listed first; Cursor also injects a set of base
    fields into every hook call (see https://cursor.com/docs/hooks#common-schema).
    """

    command: str
    # Not required fields for this hook
    cwd: str | None = None
    model: str | None = None
    hook_event_name: str | None = None
    cursor_version: str | None = None
    conversation_id: str | None = None
    generation_id: str | None = None
    user_email: str | None = None
    transcript_path: str | None = None
    sandbox: bool = False
    workspace_roots: list[str] = field(default_factory=list)

    @classmethod
    def loads(cls, raw_json: str) -> Self:
        """Parse JSON *stdin_text* into a :class:`BeforeShellExecutionInput`.

        Unknown fields are silently dropped so that new Cursor base fields never
        cause a ``TypeError`` that would make the hook fail open.

        Examples:
            >>> BeforeShellExecutionInput.loads('not json')
            Traceback (most recent call last):
            ...
            ValueError: Invalid JSON: not json
            >>> BeforeShellExecutionInput.loads('[]')
            Traceback (most recent call last):
            ...
            ValueError: Invalid JSON: []
            >>> BeforeShellExecutionInput.loads('{"command": "echo hi"}').command
            'echo hi'
            >>> BeforeShellExecutionInput.loads('{"command": "echo hi", "unknown_field": 1}').command
            'echo hi'
        """
        return parse_hook_json(raw_json, cls)

    @property
    def command_cleaned(self) -> str | None:
        command = self.command.strip()
        if not command:
            return None
        return command


class PassthroughOutput(TypedDict, total=False):
    """Empty output that tells Cursor to pass the tool call through unchanged."""


class AllowOutput(TypedDict):
    permission: Literal["allow"]


class DenyOutput(TypedDict):
    permission: Literal["deny"]
    user_message: str
    agent_message: str


class RewriteOutput(AllowOutput):
    """Response that rewrites the tool input."""

    updated_input: dict[str, str]


@dataclass(frozen=True, slots=True)
class PreToolUseOutput:
    """Outcome of evaluating a preToolUse hook call.

    See https://cursor.com/docs/hooks#common-schema for the output schema for each hook type.
    """

    output: PassthroughOutput | AllowOutput | RewriteOutput | DenyOutput
    exit_code: Literal[0] = 0


@dataclass(frozen=True, slots=True)
class BeforeShellExecutionOutput:
    """Outcome of evaluating one shell command string.

    See https://cursor.com/docs/hooks#common-schema for the output schema for each hook type.
    """

    output: AllowOutput | DenyOutput
    exit_code: Literal[0, 2]
