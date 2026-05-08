import asyncio
import json
import os
import signal
import threading
import uuid
import webbrowser
from pathlib import Path

import uvicorn
from fastapi import FastAPI
from fastapi.responses import HTMLResponse, StreamingResponse
from pydantic import BaseModel

app = FastAPI()
HTML_PATH = Path(__file__).parent / "index.html"
jobs: dict[str, dict] = {}


@app.get("/")
async def index():
    return HTMLResponse(HTML_PATH.read_text(encoding="utf-8"))


class RunRequest(BaseModel):
    cmd: str


@app.post("/run")
async def run_job(req: RunRequest):
    job_id = str(uuid.uuid4())
    jobs[job_id] = {"process": None, "cmd": req.cmd}
    return {"job_id": job_id}


@app.get("/stream/{job_id}")
async def stream(job_id: str):
    if job_id not in jobs:
        async def _not_found():
            yield f"data: {json.dumps({'error': 'job not found', 'done': True})}\n\n"
        return StreamingResponse(_not_found(), media_type="text/event-stream")

    async def generate():
        job = jobs[job_id]
        cmd = job["cmd"]
        try:
            process = await asyncio.create_subprocess_shell(
                cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
                env={**os.environ, "PYTHONUNBUFFERED": "1"},
                start_new_session=True,
            )
            job["process"] = process
            async for line in process.stdout:
                text = line.decode("utf-8", errors="replace").rstrip()
                yield f"data: {json.dumps({'line': text})}\n\n"
            await process.wait()
            yield f"data: {json.dumps({'done': True, 'returncode': process.returncode})}\n\n"
        except Exception as e:
            yield f"data: {json.dumps({'error': str(e), 'done': True})}\n\n"
        finally:
            jobs.pop(job_id, None)

    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )


@app.post("/stop/{job_id}")
async def stop_job(job_id: str):
    if job_id in jobs:
        proc = jobs[job_id].get("process")
        if proc and proc.returncode is None:
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
            except (ProcessLookupError, PermissionError):
                pass
            except Exception:
                proc.terminate()
    return {"ok": True}


@app.post("/pause/{job_id}")
async def pause_job(job_id: str):
    if job_id in jobs:
        proc = jobs[job_id].get("process")
        if proc and proc.returncode is None:
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGSTOP)
            except Exception:
                pass
    return {"ok": True}


@app.post("/resume/{job_id}")
async def resume_job(job_id: str):
    if job_id in jobs:
        proc = jobs[job_id].get("process")
        if proc and proc.returncode is None:
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGCONT)
            except Exception:
                pass
    return {"ok": True}


if __name__ == "__main__":
    def _open_browser():
        import time
        time.sleep(1.5)
        webbrowser.open("http://localhost:8765")

    threading.Thread(target=_open_browser, daemon=True).start()
    print("X-gallery-dl-commander 起動中...")
    print("ブラウザで http://localhost:8765 を開きます")
    print("停止するには Ctrl+C を押してください")
    uvicorn.run(app, host="127.0.0.1", port=8765, log_level="warning")
