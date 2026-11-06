---
name: sync
description: HayHire: Refresh the user's application history and recruiter outreach stats from Gmail and sync them to the tracker page. Use when asked to update, sync or refresh the application history or recruiter outreach pages.
---

# Sync application history

## Setup (read first)

1. Read `~/.claude/job-agent-private/config.json` (a link to the user's private folder, made by the `hayhire:setup` skill). Every `<NAME>` placeholder in this skill is a value from it (`<TRACKER_URL>`, `<PRIVATE_DIR>`, `<JOBS_DIR>`, ...). If it is missing, HayHire is not set up yet: offer to run `hayhire:setup`.
2. Read `<PRIVATE_DIR>/notes/sync-applications.md` if it exists: the user's own rules for this skill. They add to this file and win where they disagree.

- Code: `<EMAIL_FETCHER_DIR>` (run every command from there, with `venv/bin/python`)
- Page: the tracker page, <TRACKER_URL>

Rules: never access Gmail directly; only the scripts read it, read-only. Only write `email_applications` or `recruiter_outreach`, never `jobs`. Print counts only, never email rows or recruiter details.

## Application history (`email_applications`)

1. Read the artifact. Its data is shared as the user chose (`<TRACKER_SHARING>`, default `private`); do not stop because the page is shared. If `<TRACKER_SHARING>` lets other people read `email_applications` and this is the first sync since that choice, remind the user once that history rows include the Gmail account address and a Gmail link (the link only opens for someone signed in to that mailbox).
2. Run `venv/bin/python run.py tracker`. If it ends with skipped accounts, tell the user which, and stop unless they say to go on.
3. Do not download the page's rows: the database refuses to save them to files. The sync compares against the local copy in `data/sync/mirror/email_applications`, which only changes through these steps and the apply skill.
4. Run `venv/bin/python sync_prepare.py`. It merges the results into the page rows and writes `data/sync/plan.json`. It never deletes: rows the apply skill wrote are filled in when their email arrives, and email rows a scan no longer finds are flagged for review.
5. If the plan changes more than 30 rows, show the user the counts (new, updated) and wait for approval before writing.
6. Apply each batch in `data/sync/plan.json` with ArtifactData `batch`, using its entries as `writes`. If a batch is refused because a row changed on the page, stop: the local copy is out of date. Tell the user, and with their approval refresh it by reading the page's rows into the conversation (`list` without `out_dir`) and rewriting `data/sync/mirror/email_applications`, one JSON file per row with only the row's fields, and its version in `data/sync/versions.json`.
7. Run `venv/bin/python sync_prepare.py --applied`, which records the new versions and updates the local copy, then run step 4 again. The result must be 0 writes.
8. Report the totals: applications, rejected, no response, still waiting, needs review.
9. Run the `hayhire:apply` skill's pending check ("Was it submitted?"). New confirmation emails can show that a filled form was submitted; that check, not this skill, marks the job applied.

## Recruiter outreach (`recruiter_outreach`)

Same steps with `venv/bin/python run.py outreach`, collection `recruiter_outreach`, folder `data/sync/outreach` (local copy in `data/sync/outreach/mirror/recruiter_outreach`), and `outreach` added to each `sync_prepare.py` command. This collection mirrors the results, so its plan can delete rows.
