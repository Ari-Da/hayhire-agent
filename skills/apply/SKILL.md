---
name: apply
description: Fill out a job application in the user's chosen browser (their own Chrome with Claude in Chrome, or the Claude app's built-in browser) from their saved profile, save a PDF record, and after they submit, mark the job applied and add it to the Application History page. Use when the user says "apply to <job number>" (e.g. "apply to 1104-02"), "printout", or "submitted" / "applied" for a job.
---

# Apply

## Setup (read first)

1. Read `~/.claude/job-agent-private/config.json` (a link to the `private` folder next to this repo, made by `install.sh`). Every `<NAME>` placeholder in this skill is a value from it (`<TRACKER_URL>`, `<PRIVATE_DIR>`, `<JOBS_DIR>`, ...). Stop and ask if it is missing.
2. Read `<PRIVATE_DIR>/notes/apply.md` if it exists: the user's own rules for this skill. They add to this file and win where they disagree.

## Hard rules (never break these)

- Never click Submit. The user reviews every form and submits it themselves.
- Never tick consent, terms or privacy boxes, never solve CAPTCHAs, never create accounts, never sign in or type passwords.
- LinkedIn and Handshake are read-only (jobs tab only).
- Use only the browser the user chose, `<APPLY_BROWSER>` (see "Which browser" below). With `chrome`, follow "Browser safety" in `<SKILLS_DIR>/job-search/SKILL.md` (pin `<BROWSER_NAME>` by name and device id from `<PRIVATE_DIR>/browsers.json`; stop if it does not match).
- Never overwrite `applied` / `appliedAt` the user already set, and never write to another person's tracker.

## Files

- Form answers and standing rules: `<PRIVATE_DIR>/apply/profile.md` (read it fully before each application)
- Workday quirks: `<SKILLS_DIR>/apply/workday.md`, then `<PRIVATE_DIR>/notes/workday.md` (read both for any `*.myworkdayjobs.com` form)
- Resumes: attach only from `<JOBS_DIR>/resume/` (versions and when to use each are in `profile.md`)
- Cover letters: the `cover-letter` skill, output in `<JOBS_DIR>/cover_letters/`
- Records: `<JOBS_DIR>/applications/`
- Tracker page: <TRACKER_URL> (who can read its data is the user's choice, `<TRACKER_SHARING>`; see the `job-agent-setup` skill)

## Which browser

| `<APPLY_BROWSER>` | Where the form is filled | Resume and cover letter | Record |
|---|---|---|---|
| `chrome` | the user's Chrome, through Claude in Chrome | attached by the agent | PDF of the filled form |
| `built-in` | the Claude app's built-in browser | the agent cannot upload files: it prepares them and tells the user which file goes in which field | PDF if the browser can print one, otherwise a Markdown record of every answer |

- `chrome`, but the extension's tools are missing or no browser is connected: stop and say the extension is not connected. Offer to use the built-in browser for this one application; never switch the setting on your own.
- `none`, or `built-in` with its tools missing (for example the terminal app): say that automatic applying does not work here and stop. Do not fill anything. "submitted" still works, so the user can apply by hand and still log it.
- Not set: ask which browser to use (the `job-agent-setup` skill explains the choice), and save the answer.

## "apply to <MMDD-NN>"

1. Find the job: the `jobs` document whose id starts with `r<MMDD>-<NN>-` (e.g. "1104-02" is `r1104-02-<company>`). If it is already `applied: true`, say so and ask before going on.
2. Open the job's `url` in the chosen browser. With `chrome`, pin the local browser first and use the tab group (create the group if it is gone, per the browser safety rules). With `built-in`, open it in a new built-in browser tab.
3. Fill the form from `profile.md`. Ask when a question is not covered; never guess. Salary questions are the exception: suggest a figure as in "Salary questions" below.
4. Resume: pick it from `<JOBS_DIR>/resume/`. Cover letter: only if the form has a cover letter field, generate it with the `cover-letter` skill. With `chrome`, attach both. With `built-in`, leave the upload fields empty and list them for the user with the full path of each file. If `<PRIVATE_DIR>/cover-letter/facts.json` does not exist, cover letters were skipped in setup: leave the field empty (or skip it if optional) and say so.
5. Essays: use saved answers verbatim where they fit, otherwise draft from the resume and website and flag each draft for their review.
6. Save a record of the filled form: `<JOBS_DIR>/applications/<Company>_<Role>_Application_Record_<YYYY-MM-DD>.pdf`. If the browser cannot print a PDF, save the same name as `.md` with every question and answer.
7. Add the job to `<PRIVATE_DIR>/jobs/pending_submit.json` (create it if missing, `chmod 600`): `{"jobsId", "company", "role", "url", "tabId", "filledAt"}`, where `tabId` is the browser tab and `filledAt` is today (YYYY-MM-DD).
8. Stop and tell them the form is ready to review and submit, listing anything left blank, every drafted essay, the salary figure with its reasons, and (with `built-in`) the files they need to upload. Add one line: Say "submitted" when done, or just carry on and I'll check the tab next time.

## Salary questions

When a form asks for expected or desired pay, fill in a figure that fits this job, this place and this person, and explain it. The user can always change it before submitting.

1. **The user's rule wins.** If `profile.md` has a salary rule (for example a floor, "always a range" or "write negotiable when allowed"), follow it, and use the steps below only for what it leaves open. Never go below a floor the user set.
2. **Gather the facts:**
   - **The posting's own pay range,** from the job page or the `salaryRange` field on the tracker row. Many US states (for example California, Colorado, New York and Washington) require one. It is the strongest anchor.
   - **Location:** the job's city, or the user's city for a remote role. Pay differs a lot by city.
   - **Level, requirements and responsibilities:** title, level (new grad, I, II), years asked for, the skills the role stresses, and what the person would actually do (build features under guidance, own a system, lead a project, mentor others).
   - **The user's fit, from `profile.md` and the resume:** years of relevant experience, degree level, and how closely past work matches both the requirements and the responsibilities. Look at what they actually did (shipped products, owned systems, led work, research), not only job titles.
3. **No posted range:** estimate one from public data for the same role, level and city (for example levels.fyi, the company's pay ranges for the same role in other states, or the US Bureau of Labor Statistics). Use at least two sources when you can, and prefer the same company. Say clearly that it is an estimate.
4. **Place the user inside the range by fit. Do not default to the low end:** each person's place depends on their own experience against this job.
   - Lower part: they meet the minimum, and the responsibilities are a step up from what they have done.
   - Middle: they meet the requirements well, and have done similar work before (for example relevant internships, or a master's for a new-grad role).
   - Upper part: they clearly exceed the requirements, and have already carried responsibilities like these.
   Never above the posted maximum or below the posted minimum.
5. **Match the field:** a single number when it asks for one, a range when it allows text (narrow, about 10 to 15 percent wide), the nearest option in a dropdown, hourly for internships paid by the hour, the posting's currency, and base pay unless the form asks for total pay. Use round numbers.
6. **Explain it** in the "ready to review" message, in two or three lines: the figure, the range it came from (posted, or estimated and from which sources), and why the user sits where they do. For example: "Salary: $118,000. Posted range $105,000 - $150,000 (Seattle). You meet the requirements with a relevant master's and one ML internship, so lower-middle of the band."

## Was it submitted? (pending check)

The user does not have to say "submitted". Neither browser tells the agent when Submit is clicked, so it checks later, in this order. Run this check at the start of every `apply` command, every `job-pipeline` command, and at the end of "update history" (the `sync-applications` skill calls it). Skip it when `pending_submit.json` is missing or empty.

For each job in `pending_submit.json`:

1. **Already recorded:** the `jobs` row is `applied: true` (the user said "submitted" or ticked it on the page). Remove it from the list.
2. **The tab shows a confirmation:** find the tab by `tabId`, or by `url` in this session's tabs (with `chrome`, pin the local browser first). Read the page text and URL. A confirmation is a clear "thank you for applying", "application submitted / received" message, or a confirmation URL (`/thanks`, `/confirmation`, `/submitted`). If found, do every "submitted" step below for that job, then remove it. A form that still shows its fields and a Submit button is not submitted: keep it. Unclear: keep it and ask the user once.
3. **A confirmation email arrived:** look in the local copy of the history (`<EMAIL_FETCHER_DIR>/data/sync/mirror/email_applications/`) for a row with the same company (same matching as "submitted" step 3), a similar role, and `appliedDate` on or after `filledAt` minus 1 day. If found, mark the `jobs` row (`applied: true`, `appliedAt` = that row's `appliedDate`, with `if_version`), do not add a `skill-...` row (the email row is the record), and remove the job from the list.
4. **No sign yet:** keep it. If the tab is gone (closed or used for another site), the email is the only remaining signal. After 14 days, ask the user once: applied or not? Then record it or remove it.

Report in one line what was logged and how ("1104-02: confirmation page", "1104-05: confirmation email"), and say nothing when nothing changed. Never mark a job applied from a guess.

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
4. Close the job's tab, and remove the job from `<PRIVATE_DIR>/jobs/pending_submit.json`.
5. Confirm in one short message: record saved, job marked applied, history updated.
