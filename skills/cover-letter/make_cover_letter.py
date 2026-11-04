#!/usr/bin/env python3
"""Generate a tailored cover letter PDF.

Usage: python3 make_cover_letter.py job.json
job.json keys:
  title        exact job title from the posting (goes bold after "RE:")
  short_title  natural short form for paragraph 1, e.g. "Software Engineering Intern"
  company      company name
  mission      phrase completing "...the commitment <company> has toward ..."
  para3        full text of paragraph 3 (tailored skills and experience)
  date         optional, defaults to today (e.g. "October 12, 2026")
Output: <private>/jobs/cover_letters/<Name>_Cover_Letter_<Position>_<Company>.pdf
Personal details and the fixed paragraphs come from <private>/cover-letter/facts.json.
<private> is the "private" folder next to this repo, or $JOB_AGENT_PRIVATE.
"""
import sys, json, re, subprocess, tempfile, html, os, datetime, pathlib

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# The skill folder is linked into ~/.claude/skills, so resolve the link to find the repo
REPO = pathlib.Path(__file__).resolve().parents[2]
PRIVATE = pathlib.Path(os.environ.get("JOB_AGENT_PRIVATE", REPO.parent / "private")).expanduser()
OUT_DIR = PRIVATE / "jobs" / "cover_letters"
FACTS = json.loads((PRIVATE / "cover-letter" / "facts.json").read_text())
TEMPLATE = pathlib.Path(__file__).with_name("template.html")

def words(s):
    return [w for w in re.sub(r"[^A-Za-z0-9 ]+", " ", s).split() if w]

def filename(title, company):
    pos = re.split(r"\s[-–—]\s", title)[0]          # drop " - Austin, TX" style location
    pos = re.sub(r"Software\s+Engineer(ing)?", "Swe", pos, flags=re.I)
    return "_".join(words(FACTS["name"])) + "_Cover_Letter_" + "_".join(words(pos) + words(company)) + ".pdf"

def esc(s):
    return html.escape(s, quote=False)

# The closing may be several lines, shown with line breaks between them.
def lines(value):
    return "<br>".join(esc(line) for line in ([value] if isinstance(value, str) else value))

def build_page(job):
    date = job.get("date") or datetime.date.today().strftime("%B %-d, %Y")
    page = TEMPLATE.read_text()
    for k, v in FACTS.get("header", {}).items():
        page = page.replace("{{%s}}" % k.upper(), esc(v))
    page = page.replace("{{NAME}}", esc(FACTS["name"])).replace("{{EXPERIENCE}}", esc(FACTS["experience"]))
    page = page.replace("{{CLOSING}}", lines(FACTS["closing"])).replace("{{INTRO}}", esc(FACTS["intro"]))
    for k, v in {"DATE": date, "RE_TITLE": job["title"], "SHORT_TITLE": job["short_title"],
                 "COMPANY": job["company"], "MISSION": job["mission"], "PARA3": job["para3"]}.items():
        page = page.replace("{{%s}}" % k, esc(v))
    return page

def main(path, replace=False):
    job = json.load(open(path))
    page = build_page(job)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / filename(job["title"], job["company"])
    if out.exists() and not replace:
        n = 2
        while out.with_name(f"{out.stem}_{n}.pdf").exists(): n += 1
        out = out.with_name(f"{out.stem}_{n}.pdf")
    with tempfile.TemporaryDirectory() as d:
        h = pathlib.Path(d) / "letter.html"; h.write_text(page)
        subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                        "--virtual-time-budget=8000", f"--print-to-pdf={out}", f"file://{h}"],
                       check=True, capture_output=True)
    print(out)

if __name__ == "__main__":
    main(sys.argv[1], '--replace' in sys.argv)
