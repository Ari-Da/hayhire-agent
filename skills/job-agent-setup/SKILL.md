---
name: job-agent-setup
description: First-time setup of the job agent - read the user's resume, fill in what it shows, ask the rest as clickable questions, and write the answers to the private folder. Also backs up, restores and uninstalls the job agent. Use when the user says "set up job agent", "job agent setup", "update my resume", "new resume", "back up my job data", "restore my job data" or "uninstall job agent", or wants to change their profile, search preferences or cover letter facts.
---

# Job agent setup

Setup starts from the resume, so the user only answers what a resume cannot show. Ask with the clickable question tool (`AskUserQuestion`): up to 4 questions at a time, 2 to 4 options each, `multiSelect` where several answers fit; the user can always type their own answer under "Other". If that tool is not available, ask the same questions in plain chat.

1. Find the private folder: `~/.claude/job-agent-private` (made by `install.sh`). If it is missing, ask the user to run `./install.sh` from the repo first. If `~/hayhire-backups/` holds a `hayhire-backup-*.tar.gz`, ask (clickable) whether to restore it first (see "Restore") or start fresh. Read `docs/setup-questionnaire.md` in the repo (this skill's folder is `<repo>/skills/job-agent-setup`): it lists every topic and where each answer is saved.
2. **Resume first.** Ask for the resume: drop the PDF into the chat, or give its path. Copy it into `<JOBS_DIR>/resume/` (keep its file name, `chmod 600`); this is the file `apply` uploads. Ask (clickable) whether there are other versions, for example one for ML roles and one for software roles, and when each is used; record that under "Resume versions" in `apply/profile.md`. No resume yet: skip to step 4 and ask the resume topics too.
3. **Read it and fill in what it shows.** Read the whole resume and take only what is written: name, email, phone, city, links, education (school, degree, field, dates, GPA), work history (employer, title, dates, bullets), projects and skills. Never guess or improve anything; leave a field empty when the resume does not say. Show a short summary grouped by section, then confirm it with clickable questions, one per section, for example "Work history: 3 jobs found, the latest Example Corp, Software Engineer (2022 - 2025). Right?" with options "Looks right" and "Fix something". Fix what the user corrects.
4. **Ask what a resume cannot show**, a few clickable questions at a time, offering likely options from the resume. Quick start first:
   - Work authorization: needs sponsorship now / in the future / never; current status (for example student visa with work permission, work visa, permanent resident, citizen, or Other). Ask only what forms need; never ask for ID numbers.
   - Goal: full-time, internship or both; roles in priority order (`multiSelect`, roles suggested from the resume); the most years of experience a posting may ask for.
   - Location, as two clickable questions (`multiSelect`), each with "Other" for anything not listed:
     - **Cities:** suggest the resume's city and two or three large job markets near it. The user types any others.
     - **Remote:** "Remote: US", "Remote: Europe", "Remote: anywhere", "No remote". The user types other regions or limits under "Other" (for example "Remote: Canada" or "US Eastern time zone only").
     Then ask (clickable) which work styles are fine: on-site, hybrid, remote.
   - Graduation (students): is the date certain, or could it move?
   - Cover letters: yes or skip. If yes, draft the fixed paragraphs from the resume for approval (part C).
   - Tracker link and sharing (step 6), and browser (step 7).
   Then offer the rest (standard answers, self-identification, companies to check or skip, words that must never be published). They can wait: `apply` asks when a form needs something missing and saves the answer.
   **Check typed answers before saving.** Anything typed under "Other" that feeds the search (locations, remote regions, role titles):
   - Clean it up: fix typos, add the state or country ("Austin" becomes "Austin, TX"), expand regions and nicknames into the places the search looks for ("Bay Area" becomes San Francisco, San Jose, Oakland and Palo Alto; "NYC" becomes New York, NY; "MLE" becomes Machine Learning Engineer).
   - Never guess when it is unclear: ask with a clickable question ("Portland: Oregon or Maine?").
   - Flag anything the search does not cover: "London is outside the US, and job search only covers the US. Keep it anyway, or drop it?"
   - Confirm the final list in priority order with one clickable question ("Your locations: 1) New York, NY 2) Remote: US 3) Austin, TX. Right?"), with "Looks right" or "Change it". The order is the priority: jobs in the first choice come first.
   Apply the same checks whenever the user changes these answers later.
5. Write each answer where the questionnaire's table says: `config.json`, `apply/profile.md` (format of `examples/profile.example.md`), `cover-letter/facts.json` (format of `examples/facts.example.json`), `notes/job-search.md`. Read each file before writing; never overwrite an existing answer without showing the old and new value and asking. Never ask for or store passwords, ID numbers or bank details. Keep every file in `private/` readable only by the user (`chmod 600`).
6. **Tracker sharing.** Ask who may see the tracker's data when its link is shared, and save the answer as `TRACKER_SHARING` in `config.json` (default `private`). It is the user's choice: explain what each level shows, then do what they pick. Apply it as the page's `db` access rules (`read` levels; writes stay with the owner):

   | `TRACKER_SHARING` | `jobs` | `email_applications` | `recruiter_outreach` |
   |---|---|---|---|
   | `private` | owner | owner | owner |
   | `applications` | view | view | owner |
   | `everything` | view | view | view |

   For example `applications` is `rules: [{path: "jobs", read: "view", write: "owner"}, {path: "email_applications", read: "view", write: "owner"}, {path: "recruiter_outreach", read: "owner", write: "owner"}]`. Rules cover whole collections, not single fields, so say plainly what a level exposes: history rows hold the Gmail account address and a Gmail link (the link only opens for someone signed in to that mailbox), and outreach rows name companies the user emailed. Sharing the link (the Share menu) and these rules are separate: a viewer sees the page, but only the data the rules allow. When the user changes the level later, update both the config and the page's rules.
7. **Browser for applying.** Save the answer as `APPLY_BROWSER` in `config.json`: `chrome`, `built-in` or `none`.
   - First check what this session can use, without opening anything:
     - **Claude in Chrome:** tools named `mcp__claude-in-chrome__*` (or a single `enable__mcp__claude-in-chrome` tool) are present. If they are, ask permission, then call `list_connected_browsers`. A listed browser means the extension is installed and connected.
     - **Built-in browser:** tools named `mcp__Claude_Browser__*` are present (the Claude desktop app).
   - **Extension connected:** say so, and ask whether to apply there. If yes, set `chrome`, ask the user to name this computer's browser, and save its name and device id in `browsers.json` (see "Browser safety" in the `job-search` skill). The `apply` skill then fills whole forms, uploads included.
   - Ask which browser the user normally uses. The extension runs in Google Chrome; Edge and other Chromium browsers (Brave, Arc, Vivaldi, Opera) may work through Claude Code but are not officially supported. Firefox and Safari have no Claude extension: recommend `built-in`.
   - **Extension not found:** do not push it. Offer `built-in` if it is available, and explain the trade-off: the agent fills the form, and the user uploads the resume and cover letter. If the user still wants their own browser, set `chrome` and give the steps: install Claude in Chrome from https://claude.com/chrome, sign in with the same Claude account, connect it, then say "set up job agent" again to name the browser. Until it is connected, `apply` stops and says it is waiting for the extension.
   - **Neither available** (for example the terminal without the desktop app): set `none` and tell the user plainly that automatic applying does not work here. Everything else still works: job search, cover letters, the tracker and email tracking. Run setup again once a browser is available.
8. Finish with a summary of what was saved, what is still missing, and the first command to try: "run a job for 5".

## Updating the resume

When the user says "update my resume" or "new resume", or shares a new resume file:

1. Ask (clickable) whether it **replaces** the current default or is **another version** (and when to use it).
2. Copy it into `<JOBS_DIR>/resume/` (`chmod 600`). When it replaces one, move the old file to `<JOBS_DIR>/resume/archive/` with its date; never delete it. Update "Resume versions" in `apply/profile.md`.
3. Read the new resume and compare it with `apply/profile.md`: new or changed jobs, dates, titles, education, skills, contact details. Show only the differences and confirm them with clickable questions ("Add: Example Corp, ML Engineer (2026 - now)?"). Write the confirmed ones.
4. If cover letters are on and the experience paragraph in `cover-letter/facts.json` no longer matches, offer an updated draft for approval.
5. Confirm in one line which file `apply` now uploads by default.

## Back up ("back up my job data")

The tracker's rows live on claude.ai, not on this computer; Insights is drawn from them, so it needs no backup of its own.

1. Export the tracker: for each collection (`jobs`, `email_applications`, `recruiter_outreach`), read every row with ArtifactData `list` (no `out_dir`; page with `cursor`) and write `<PRIVATE_DIR>/backup/tracker/<collection>.json` as a list of `{"id", "data"}`, `chmod 600`. Write the counts to `<PRIVATE_DIR>/backup/tracker/manifest.json` with today's date and `<TRACKER_URL>`.
2. Run `<repo>/backup.sh`. It packs `private/` (with that export), the email tracking state and settings into `~/hayhire-backups/hayhire-backup-<date>.tar.gz`, readable only by the user. Gmail login tokens are left out on purpose.
3. Report the archive path and the row counts. Remind the user the archive holds personal data: keep it on this computer, never in a repo.

## Uninstall ("uninstall job agent")

1. Ask with one clickable dialog: back up first (yes, recommended / no); the tracker page (keep it / delete it after the backup); the `job-agent` folder (keep it / move it to the Trash).
2. If backing up, do "Back up" above and stop if it fails.
3. If the user chose to delete the tracker page, delete it with the Artifact tool only after the backup succeeded (they confirm the delete).
4. Run `<repo>/uninstall.sh --no-backup` plus `--delete-folder` or `--keep-folder`. It removes the skill links and the private-folder link, and only links that point into this copy.
5. Tell the user what is left for them: removing Gmail access at https://myaccount.google.com/permissions, and this project's Claude Code memory in `~/.claude/projects/` (offer to delete that folder; ask first). To set up again: clone, `./public/install.sh`, then "restore my job data".

## Restore ("restore my job data")

1. List the archives in `~/hayhire-backups/`, newest first, and ask (clickable) which one. Extract it into a new temporary folder; never extract straight over existing files.
2. **Private files:** copy each file into `<PRIVATE_DIR>`. Where the current file is still the example from `examples/`, replace it; where it has the user's own answers, show what differs and ask. Keep `chmod 700` on folders and `600` on files.
3. **Email tracking:** if `<EMAIL_FETCHER_DIR>` exists, copy back `settings.json`, `credentials.json` and `data/` (ask before replacing anything already there). Gmail needs a fresh sign-in, because tokens are not backed up.
4. **Tracker:** the old page may be gone, so ask for the tracker to use (a new page, or the one from setup) and set `TRACKER_URL` in `config.json`. List its collections first: if they already have rows, ask before adding, and never overwrite a row with the same id without asking. Write the rows from `backup/tracker/*.json` with ArtifactData `batch`, keeping their ids. Apply the `TRACKER_SHARING` rules (step 6 of setup).
5. **Local copy for the email sync:** the restored rows have new versions, so refresh the local copy as in step 6 of the `sync-applications` skill (`data/sync/mirror/` and `data/sync/versions.json`, and the same for outreach). Then `sync_prepare.py` must plan 0 writes.
6. Report the counts restored per collection, and run setup only for anything still missing. Delete the temporary folder.
