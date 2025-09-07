import re
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
AWS_KEY = re.compile(r"AKIA[0-9A-Z]{16}")
GENERIC_KEY = re.compile(r"(?i)(api[_-]?key|token|secret)\s[:=]\s([A-Za-z0-9\-._]{16,})")
def redact(s: str) -> str:
    if not s:
        return s
    s = EMAIL.sub("[REDACTED:EMAIL]", s)
    s = AWS_KEY.sub("[REDACTED:AWS_KEY]", s)
    s = GENERIC_KEY.sub(r"\1: [REDACTED:KEY]", s)
    return s
