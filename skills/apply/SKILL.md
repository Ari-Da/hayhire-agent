---
name: apply
description: Fill out a job application in the user's local Chrome from their saved profile, save a PDF record, and after they submit, mark the job applied and add it to the Application History page. Use when the user says "apply to <job number>" (e.g. "apply to 1104-02"), "printout", or "submitted" / "applied" for a job.
---

# Apply

## Setup (read first)

1. Read `~/.claude/job-agent-private/config.json` (a link to the `private` folder next to this repo, made by `install.sh`). Every `<NAME>` placeholder in this skill is a value from it (`<TRACKER_URL>`, `<PRIVATE_DIR>`, `<JOBS_DIR>`, ...). Stop and ask if it is missing.
2. Read `<PRIVATE_DIR>/notes/apply.md` if it exists: the user's own rules for this skill. They add to this file and win where they disagree.

## Hard rules (never break these)

- Never click Submit. The user reviews every form and submits it themselves.
- Never tick consent, terms or privacy boxes, never solve CAPTCHAs, never create accounts, never sign in or type passwords.
- LinkedIn and Handshake are read-only (jobs tab only).
- Use only the local browser, following "Browser safety" in `<SKILLS_DIR>/job-search/SKILL.md` (pin `<BROWSER_NAME>` by name and device id from `<PRIVATE_DIR>/browsers.json`; stop if it does not match).
- Never overwrite `applied` / `appliedAt` the user already set, and never write to another person's tracker.

## Files

- Form answers and standing rules: `<PRIVATE_DIR>/apply/profile.md` (read it fully before each application)
- Workday quirks: `<SKILLS_DIR>/apply/workday.md`, then `<PRIVATE_DIR>/notes/workday.md` (read both for any `*.myworkdayjobs.com` form)
- Resumes: attach only from `<JOBS_DIR>/resume/` (versions and when to use each are in `profile.md`)
- Cover letters: the `cover-letter` skill, output in `<JOBS_DIR>/cover_letters/`
- Records: `<JOBS_DIR>/applications/`
- Tracker page: <TRACKER_URL> (who can read its data is the user's choice, `<TRACKER_SHARING>`; see the `job-agent-setup` skill)

## "apply to <MMDD-NN>"

1. Find the job: the `jobs` document whose id starts with `r<MMDD>-<NN>-` (e.g. "1104-02" is `r1104-02-<company>`). If it is already `applied: true`, say so and ask before going on.
2. Pin the local browser, then open the job's `url` in the tab group (create the group if it is gone, per the browser safety rules).
3. Fill the form from `profile.md`. Ask when a question is not covered; never guess.
4. Resume: attach from `<JOBS_DIR>/resume/`. Cover letter: only if the form has a cover letter field, generate it with the `cover-letter` skill and attach it. If `<PRIVATE_DIR>/cover-letter/facts.json` does not exist, cover letters were skipped in setup: leave the field empty (or skip it if optional) and say so.
5. Essays: use saved answers verbatim where they fit, otherwise draft from the resume and website and flag each draft for their review.
6. Save a PDF record of the filled form: `<JOBS_DIR>/applications/<Company>_<Role>_Application_Record_<YYYY-MM-DD>.pdf`.
7. Stop and tell them the form is ready to review and submit, listing anything left blank and every drafted essay.

## "printout"

Save or refresh the PDF record of the current form (step 6).

## "submitted" / "applied"

Do all of these in the same turn:

1. Save `<Company>_<Role>_Submitted_<YYYY-MM-DD>.pdf` with the confirmation page.
2. Read the job's `jobs` document and update it with ArtifactData `update`, passing its `version` as `if_version`: `applied: true`, `appliedAt: <today>`.
3. Add the application to the history page (`email_applications`), unless it is already there:
   - First look for a row in the local copy (`<EMAIL_FETCHER_DIR>/data/sync/mirror/email_applications/`, one JSON file per row) with the same company (ignore "Inc", "LLC", " (Tier N)" and subsidiaries such as "Amazon Web Services" for Amazon), a similar role, and `appliedDate` within 5 days. If one exists, do not add a row; say so.
   - Otherwise create document `skill-<jobs id>` (e.g. `skill-r1104-02-amazon`), without `if_version`:
     `company` (the job's company, without " (Tier N)"), `role` (exact posting title), `appliedDate` (today, YYYY-MM-DD), `type` (`internship` if the title mentions intern, internship or co-op, otherwise `full-time`), `status: "applied"`, `lastUpdate` (today), `sourceAccount: null`, `emailUrl: null`, `needsReview: false`, `reviewReason: null`, `origin: "skill"`, `jobsId: "<jobs id>"`.
   - Save the same fields as a JSON file at `<EMAIL_FETCHER_DIR>/data/sync/mirror/email_applications/skill-<jobs id>.json`, readable only by the current macOS user (`chmod 600`). The email sync compares against this local copy instead of downloading the page, so a row missing from it would be added twice.
   - The email sync fills in the email link later and never deletes this row.
4. Close the job's tab.
5. Confirm in one short message: record saved, job marked applied, history updated.
