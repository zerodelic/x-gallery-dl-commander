import sys
from pathlib import Path

# app/main.py is not an installable package; add its directory to sys.path
# so tests can `import main` directly regardless of the current working dir.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "app"))

import pytest  # noqa: E402


@pytest.fixture(autouse=True)
def _reset_jobs():
    import main
    main.jobs.clear()
    yield
    main.jobs.clear()
