from fastapi import FastAPI, Header, HTTPException, Request
from pydantic import BaseModel
from typing import List, Optional
from .telemetry import log_digest

app = FastAPI(title="CoAgent Facade", version="0.1.1")

class IssueCreate(BaseModel):
    repo: str
    title: str
    body: Optional[str] = None
    labels: Optional[List[str]] = None

def require_scope(auth: Optional[str], need: str):
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="missing bearer token")
    if need not in auth:
        raise HTTPException(status_code=403, detail="insufficient scope")

@app.middleware("http")
async def digest_mw(request: Request, call_next):
    # Record minimal request info (no bodies)
    log_digest("request", {"method": request.method, "path": request.url.path, "query": str(request.url.query)})
    resp = await call_next(request)
    # Record minimal response info
    log_digest("response", {"path": request.url.path, "status": resp.status_code})
    return resp

@app.get("/healthz")
def healthz():
    return {"ok": True, "version": app.version}

@app.post("/issue.create", status_code=202)
def issue_create(payload: IssueCreate, authorization: Optional[str] = Header(default=None, convert_underscores=False)):
    require_scope(authorization, "scope:issue.create")
    log_digest("issue.create", {"repo": payload.repo, "title": payload.title})
    # TODO: enqueue to real CoAgent handler
    return {"accepted": True, "repo": payload.repo, "title": payload.title}

@app.get("/status.report")
def status_report(repo: str, authorization: Optional[str] = Header(default=None, convert_underscores=False)):
    require_scope(authorization, "scope:status.read")
    # TODO: implement real gh status read
    return {"repo": repo, "branches": [], "checks": [], "ok": True}
