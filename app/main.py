import asyncio
import json
import os
import shutil
import signal
import sys
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
_html_content = HTML_PATH.read_text(encoding="utf-8")
jobs: dict[str, dict] = {}

_SUBPROCESS_ENV: dict[str, str] = {**os.environ, "PYTHONUNBUFFERED": "1"}
if sys.platform == "darwin":
    _SUBPROCESS_ENV["PATH"] = (
        "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin"
        + ":" + (os.environ.get("PATH") or "/usr/bin:/bin")
    )
_gallery_dl_bin = shutil.which("gallery-dl", path=_SUBPROCESS_ENV.get("PATH")) or "gallery-dl"


@app.get("/")
async def index():
    return HTMLResponse(_html_content)


class RunRequest(BaseModel):
    cmd: str


@app.post("/run")
async def run_job(req: RunRequest):
    job_id = str(uuid.uuid4())
    jobs[job_id] = {"process": None, "cmd": req.cmd}

    async def _expire():
        await asyncio.sleep(30)
        job = jobs.get(job_id)
        if job and job.get("process") is None:
            jobs.pop(job_id, None)

    asyncio.create_task(_expire())
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
        if cmd.startswith("gallery-dl"):
            cmd = _gallery_dl_bin + cmd[len("gallery-dl"):]
        try:
            process = await asyncio.create_subprocess_shell(
                cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.STDOUT,
                env=_SUBPROCESS_ENV,
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
            proc = job.get("process")
            if proc and proc.returncode is None:
                try:
                    os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                except Exception:
                    try:
                        proc.terminate()
                    except Exception:
                        pass
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
    if sys.platform == "win32":
        return {"ok": False, "reason": "pause not supported on Windows"}
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
    if sys.platform == "win32":
        return {"ok": False, "reason": "resume not supported on Windows"}
    if job_id in jobs:
        proc = jobs[job_id].get("process")
        if proc and proc.returncode is None:
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGCONT)
            except Exception:
                pass
    return {"ok": True}


@app.get("/pick-directory")
async def pick_directory():
    loop = asyncio.get_running_loop()
    path = await loop.run_in_executor(None, _show_dir_dialog)
    return {"path": path}


def _show_dir_dialog() -> str:
    import sys, subprocess
    if sys.platform == "darwin":
        try:
            result = subprocess.run(
                ["osascript", "-e",
                 'POSIX path of (choose folder with prompt "保存先フォルダーを選択")'],
                capture_output=True, text=True, timeout=120,
            )
            return result.stdout.strip().rstrip("/") if result.returncode == 0 else ""
        except Exception:
            pass
    try:
        import tkinter as tk
        from tkinter import filedialog
        root = tk.Tk()
        root.withdraw()
        root.wm_attributes("-topmost", 1)
        folder = filedialog.askdirectory(title="保存先フォルダーを選択")
        root.destroy()
        return folder or ""
    except Exception:
        return ""


@app.post("/shutdown")
async def shutdown():
    def _do_shutdown():
        import time
        time.sleep(0.5)
        os.kill(os.getpid(), signal.SIGTERM)
    threading.Thread(target=_do_shutdown, daemon=True).start()
    return {"ok": True}


if __name__ == "__main__":
    def _open_browser():
        import time
        time.sleep(1.5)
        webbrowser.open("http://localhost:8766")

    threading.Thread(target=_open_browser, daemon=True).start()
    print("X-gallery-dl-commander 起動中...")
    print("ブラウザで http://localhost:8766 を開きます")
    print("停止するには Ctrl+C を押してください")
    uvicorn.run(app, host="127.0.0.1", port=8766, log_level="warning")
