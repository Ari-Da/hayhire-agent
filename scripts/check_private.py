"""Blocks a commit or push that would publish personal details.

Scans every tracked file and the whole git history for the terms in a private
blocklist kept outside the repo (one term per line), plus generic patterns.
The blocklist is private/blocklist.txt next to this repo, or $JOB_AGENT_BLOCKLIST.
Usage: python3 scripts/check_private.py [--staged]
"""
import os
import pathlib
import re
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[1]
BLOCKLIST = os.environ.get("JOB_AGENT_BLOCKLIST", str(REPO.parent / "private" / "blocklist.txt"))
PATTERNS = [
    re.compile(r"claude\.ai/(?:code/)?artifact/[A-Za-z0-9-]{8,}"),
    # Home folder paths. Split so this file does not match its own pattern
    re.compile("/" + "Users" + r"/[^/\s]+"),
    re.compile(r"\b[\w.+-]+@gmail\.com\b"),
]


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True).stdout


def main():
    if not os.path.exists(BLOCKLIST):
        sys.exit(f"Blocklist not found at {BLOCKLIST}. Create it (one private term per line) before committing.")
    terms = [line.strip().lower() for line in open(BLOCKLIST) if line.strip()]
    sources = {"staged changes": git("diff", "--cached", "-U0")}
    if "--staged" not in sys.argv:
        sources["files"] = "\n".join(open(f, errors="ignore").read() for f in git("ls-files").split() if os.path.isfile(f))
        sources["history"] = git("log", "--all", "-p", "--format=%an %ae %cn %ce %s %b")
    problems = []
    for name, text in sources.items():
        lowered = text.lower()
        problems += [f"{name}: a blocklisted term" for term in terms if term in lowered]
        problems += [f"{name}: {pattern.pattern}" for pattern in PATTERNS if pattern.search(text)]
    if problems:
        print("Private details found, nothing should be published:")
        for problem in sorted(set(problems)):
            print(" ", problem)
        sys.exit(1)
    print("No private details found.")


if __name__ == "__main__":
    main()
