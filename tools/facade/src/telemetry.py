import json, hashlib, time, os
from .util_redact import redact

LOGDIR = os.path.join(os.path.dirname(__file__), "..", "..", "logs")
os.makedirs(LOGDIR, exist_ok=True)
LOGFILE = os.path.join(LOGDIR, "telemetry.ndjson")

def log_digest(event: str, payload: dict):
    try:
        red = {}
        for k, v in payload.items():
            red[k] = redact(str(v)) if isinstance(v, (str, int, float)) else v
        dig = hashlib.sha256(json.dumps(red, sort_keys=True).encode("utf-8")).hexdigest()
        entry = {
            "ts": int(time.time()1000),
            "event": event,
            "digest": dig,
            "fields": red,
        }
        with open(LOGFILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        # telemetry must never crash the façade
        pass





