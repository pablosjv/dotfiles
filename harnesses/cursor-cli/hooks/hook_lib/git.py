"""Utilities for git related commands."""

import re

_TRAILER_KEYWORDS = (
    r"Co-authored-by|Signed-off-by|Reviewed-by"
    r"|Acked-by|Helped-by|Reported-by|Made-with"
)

TRAILER_SUBSTR: re.Pattern[str] = re.compile(
    rf"(?is)(?:{_TRAILER_KEYWORDS})\s*:",
)
"""Match a trailer keyword anywhere in a string."""

TRAILER_LINE_START: re.Pattern[str] = re.compile(
    rf"(?is)^\s*(?:{_TRAILER_KEYWORDS})\s*:",
)
"""Match a trailer keyword at the start of a line."""

TRAILER_FLAG: re.Pattern[str] = re.compile(
    r"(?<![\w-])--trailer(?![\w-])",
)
"""Match the ``--trailer`` git flag."""

TRAILER_IN_COMMIT: re.Pattern[str] = re.compile(
    rf"(?is)"
    rf"(?=.*\bcommit\b)"
    rf"(?=.*(?:{_TRAILER_KEYWORDS})\s*:)",
)
"""Match a ``git commit`` command that embeds a trailer keyword."""

RegexRule = tuple[re.Pattern[str], str]
"""A tuple of a regex pattern and a message."""


PUSH_TAIL_RULES: tuple[RegexRule, ...] = (
    (re.compile(r"(^|\s)--force(\s|$)"), 'git push must not use "--force".'),
    (re.compile(r"(^|\s)-f(\s|$)"), 'git push must not use "-f" (force).'),
    (re.compile(r"(^|\s)--mirror(\s|$)"), 'git push must not use "--mirror".'),
    (re.compile(r"(^|\s)--delete(\s|$)"), 'git push must not use "--delete".'),
    (re.compile(r"\s\+[^\s]+"), "git push must not use a + refspec (force update)."),
)

TRAILER_RULES: tuple[RegexRule, ...] = (
    (
        TRAILER_FLAG,
        (
            "Git commands must not use --trailer or other git trailer mechanisms. "
            "Use a plain commit message without trailer footers."
        ),
    ),
    (
        TRAILER_IN_COMMIT,
        (
            "Git commit commands must not include git trailer lines (e.g. Co-authored-by, "
            "Signed-off-by, Made-with) in the message."
        ),
    ),
)
