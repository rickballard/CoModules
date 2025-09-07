from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="CoAgent Facade", version="0.1.0")

class IssueCreate(BaseModel):
    repo: str
    title: str
    body: Optional[str] = None
    labels: Optional[List[str]] = None

def require_scope(auth: Optional[str], need: str):
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="missing bearer token")
    # TODO: validate token + scope properly; this is a stub
    # Reject anything not exactly the required scope for now
    if need not in auth:
        raise HTTPException(status_code=403, detail="insufficient scope")

@app.post("/issue.create", status_code=202)
def issue_create(payload: IssueCreate, authorization: Optional[str] = Header(default=None, convert_underscores=False)):
    require_scope(authorization, "scope:issue.create")
    # TODO: enqueue to real CoAgent handler; return request digest only
    return {"accepted": True, "repo": payload.repo, "title": payload.title}

@app.get("/status.report")
def status_report(repo: str, authorization: Optional[str] = Header(default=None, convert_underscores=False)):
    require_scope(authorization, "scope:status.read")
    # TODO: query read-only status; return placeholder for now
    return {"repo": repo, "branches": [], "checks": [], "ok": True}
