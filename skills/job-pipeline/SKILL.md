---
name: job-pipeline
description: Run the user's job search end to end - find jobs, apply, record submissions, and update the application history from email. Use when the user asks for the job pipeline, its status, or "update history", or wants the next step after a job search or application.
---

# Job pipeline

## Setup (read first)

1. Read `~/.claude/job-agent-private/config.json` (a link to the `private` folder next to this repo, made by `install.sh`). Every `<NAME>` placeholder in this skill is a value from it (`<TRACKER_URL>`, `<PRIVATE_DIR>`, `<JOBS_DIR>`, ...). Stop and ask if it is missing.
2. Read `<PRIVATE_DIR>/notes/job-pipeline.md` if it exists: the user's own rules for this skill. They add to this file and win where they disagree.

The pipeline connects four skills. Each keeps its own job; this skill decides what runs next.

| Step | Skill | Trigger | Writes |
|---|---|---|---|
| 1. Find jobs | `job-search` | "run a job for 15", `/job-search 20 7`, "job run startup 10" | `jobs` (new rows) |
| 2. Fill an application | `apply` | "apply to 1104-02" | nothing on the page |
| 3. Submit | the user, by hand | they click Submit | |
| 4. Record it | `apply` | "submitted" / "applied" | `jobs.applied`, `appliedAt`; a `skill-...` row in `email_applications` |
| 5. Confirm from email | `sync-applications` | "update history" | `email_applications` (merge, never delete) |
| 6. Recruiter stats | `sync-applications` | "update outreach" | `recruiter_outreach` |

## Commands

- **"pipeline status":** read `jobs` and `email_applications` and report: jobs found in the latest run, jobs not yet applied to, applications submitted in the last 7 days, skill rows still waiting for a confirmation email, and the history totals.
- **"next":** suggest the next step from the status (for example, unapplied jobs from the latest run, or "update history" if it has not run today).
- **"update history":** follow `sync-applications`.
- **Before every command:** run the `apply` skill's pending check ("Was it submitted?"), so jobs the user submitted without saying so are logged.
- **After "submitted":** the `apply` skill adds the history row at once. Do not run the email sync automatically; the confirmation email usually arrives later. Offer "update history" when they are done applying for the day.
- **Catch-up:** if a `jobs` row has `applied: true`, an `appliedAt` on or after <HARNESS_START_DATE>, and no `skill-<jobs id>` row in `email_applications`, they ticked it on the page. Offer to add the history row as in the `apply` skill's "submitted" step 3. Never do this for earlier ticks: the email backfill already counts those.

## Rules

- One writer per collection: `job-search` adds `jobs` rows, `apply` sets `applied` / `appliedAt` (on "submitted", or from its pending check) and adds `skill-...` history rows, the email sync merges into `email_applications`, and nothing deletes history rows except the user by hand.
- Who can read the tracker's data is the user's choice, `<TRACKER_SHARING>` in the config (default `private`). Never change it on your own, and never stop because the page is shared. If the page's access rules do not match the setting, say so once and offer to fix the rules (see the `job-agent-setup` skill).
- The user submits every application themselves. Never click Submit.
- Scheduling is paused (user decision). Run steps only when asked.
