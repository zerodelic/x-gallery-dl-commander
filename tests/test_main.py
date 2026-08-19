import sys

import main
from fastapi.testclient import TestClient

client = TestClient(main.app)


# ── _resolve_cmd ─────────────────────────────────────────────

def test_resolve_cmd_substitutes_binary_path(monkeypatch):
    monkeypatch.setattr(main, "_gallery_dl_bin", "/fake/path/gallery-dl")
    result = main._resolve_cmd("gallery-dl --cookies-from-browser edge")
    assert result == "/fake/path/gallery-dl --cookies-from-browser edge"


def test_resolve_cmd_passthrough_for_other_commands():
    assert main._resolve_cmd("echo hi") == "echo hi"


# ── /run ─────────────────────────────────────────────────────

def test_run_returns_job_id_and_stores_job():
    res = client.post("/run", json={"cmd": "gallery-dl --version"})
    assert res.status_code == 200
    job_id = res.json()["job_id"]
    assert job_id in main.jobs
    assert main.jobs[job_id]["cmd"] == "gallery-dl --version"


# ── /stream ──────────────────────────────────────────────────

def test_stream_unknown_job_reports_not_found():
    res = client.get("/stream/does-not-exist")
    assert res.status_code == 200
    assert "job not found" in res.text


class _FakeStdout:
    def __init__(self, lines):
        self._lines = lines

    def __aiter__(self):
        return self._gen()

    async def _gen(self):
        for line in self._lines:
            yield line


class _FakeProcess:
    def __init__(self, lines, returncode=0, pid=12345):
        self.stdout = _FakeStdout(lines)
        self.returncode = None
        self._final_returncode = returncode
        self.pid = pid

    async def wait(self):
        self.returncode = self._final_returncode
        return self.returncode


def test_stream_runs_mocked_process_and_cleans_up_job(monkeypatch):
    async def fake_create_subprocess_shell(cmd, **kwargs):
        return _FakeProcess([b"line one\n", b"line two\n"], returncode=0)

    monkeypatch.setattr(main.asyncio, "create_subprocess_shell", fake_create_subprocess_shell)

    run_res = client.post("/run", json={"cmd": "gallery-dl --version"})
    job_id = run_res.json()["job_id"]

    stream_res = client.get(f"/stream/{job_id}")
    assert stream_res.status_code == 200
    assert "line one" in stream_res.text
    assert "line two" in stream_res.text
    assert '"done": true' in stream_res.text
    assert '"returncode": 0' in stream_res.text
    # job should be cleaned up once the stream completes
    assert job_id not in main.jobs


# ── /stop ────────────────────────────────────────────────────

def test_stop_on_unknown_job_is_noop():
    res = client.post("/stop/does-not-exist")
    assert res.status_code == 200
    assert res.json() == {"ok": True}


# ── /pause, /resume: platform gating ────────────────────────
# pause/resume are POSIX-only (SIGSTOP/SIGCONT). Running this suite on both
# windows-latest and macos-latest in CI exercises both branches for real,
# instead of relying on mocking sys.platform.

def test_pause_platform_gating():
    res = client.post("/pause/does-not-exist")
    assert res.status_code == 200
    if sys.platform == "win32":
        assert res.json() == {"ok": False, "reason": "pause not supported on Windows"}
    else:
        assert res.json() == {"ok": True}


def test_resume_platform_gating():
    res = client.post("/resume/does-not-exist")
    assert res.status_code == 200
    if sys.platform == "win32":
        assert res.json() == {"ok": False, "reason": "resume not supported on Windows"}
    else:
        assert res.json() == {"ok": True}
