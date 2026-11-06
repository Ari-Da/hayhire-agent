---
name: setup
description: HayHire: First-time setup of the job agent - read the user's resume, fill in what it shows, ask the rest as clickable questions, and write the answers to the private folder. Also backs up, restores and uninstalls the job agent. Use when the user says "set up job agent", "job agent setup", "update my resume", "new resume", "back up my job data", "restore my job data", "uninstall hayhire" or "uninstall job agent", or wants to change their profile, search preferences or cover letter facts.
---

# Job agent setup

Setup starts from the resume, so the user only answers what a resume cannot show. Ask with the clickable question tool (`AskUserQuestion`): up to 4 questions at a time, 2 to 4 options each, `multiSelect` where several answers fit; the user can always type their own answer under "Other". Give an option a description only when it adds something the label does not say ("Full-time first": "Internships too, but fewer"); when it would only repeat the label ("Full-time only": "No internships"), leave the description empty (""). If that tool is not available, ask the same questions in plain chat.

1. **Set things up, without questions.** If `~/.claude/job-agent-private` does not exist yet, run `sh ${CLAUDE_PLUGIN_ROOT}/scripts/init_private.sh` (default folder `~/job-agent/private`; pass another folder only if the user already named one). It creates the folder from the examples, readable only by the user, and links it at `~/.claude/job-agent-private`. It keeps an existing folder as it is, so it is safe to run again. Then run `sh ${CLAUDE_PLUGIN_ROOT}/scripts/check_clashes.sh` and read `${CLAUDE_PLUGIN_ROOT}/docs/setup-questionnaire.md`, which lists every topic and where each answer is saved. Say in one line where the data is kept ("Your data is kept in ~/job-agent/private, readable only by you."). Ask nothing yet, except:
   - **Backup found** (the script says so): ask (clickable) whether to restore it first (see "Restore") or start fresh.
   - **Clashing skills** (the clash check lists any): `old-hayhire` are links from an earlier install, `broken` are links to a folder that is gone, `other` are job skills from another kit. Also look at the skills this session lists: any job skill whose description does not start with "HayHire:" is not part of this plugin. Name them and say why it matters ("apply to ..." could start the wrong one), and ask (clickable) whether to move them to `~/.claude/skills-disabled/` (never delete; they load again if moved back). Skills added in the Claude app's settings can only be turned off there: say where. Either way, "hayhire ..." and `/hayhire:<skill>` always reach HayHire.
2. **Resume.** Ask for it in a plain message, not a clickable question (a click cannot carry a file). Make it the last thing in the message, on its own line, in bold, so it is clear the chat is waiting for the user, exactly:

   > 📎 **Your turn: add your resume.** Click **+** or drag the PDF into this chat, or type its path. No resume, or want to enter your details by hand? Type **skip**.

   Then stop and wait; do nothing else in that turn. Do not ask first whether they have one. When it arrives, copy it into `<JOBS_DIR>/resume/` (keep its file name, `chmod 600`); this is the file `hayhire:apply` uploads. On "skip", go to step 4 and ask the resume topics there too. Other resume versions (for example one for ML roles) can be added later with "update my resume"; mention that once at the end, not now.
3. **Read it and fill in what it shows.** Read the whole resume in one go (Read the PDF without `pages`: resumes are short, and page ranges need extra software that may be missing) and take only what is written. Never guess or improve anything; leave a field empty when the resume does not say. Confirm one section at a time, in this order: Contact, Education, Work history, Projects (only if the resume has them), Skills. For each section:
   Use the clickable question tool, one question per dialog (never bundle other questions with it). Put the results in the `question` text itself: do not rely on chat text before the dialog (the Claude app may show only its own one-line summary there), and do not use option previews. The question box shows plain text only, so write labels in CAPITALS with a colon, one field per line (real line breaks), a blank line between entries. For example the Work history question text is:

      ```
      Work history from your resume:

      TITLE: Software Engineer
      COMPANY: Example Corp
      LOCATION: New York, NY
      DATES: Jan 2022 – Jul 2025

      Wrong? Type fixes under Other: COMPANY: Acme; DATES: 2023 – 2025
      ```

   Options, always these two (the built-in Other box comes third):
   - **Correct** ("Save this section as shown"): save it and ask the next section.
   - **Incorrect** ("You'll fix it field by field next"): ask one question per field of the section, up to 4 per dialog. Each question names the field ("FIRST NAME") and has two options: "Keep: <extracted value>" and "Clear it"; Other is where the user types the new value. Then show the section again with the changes and ask Correct / Incorrect again.
   - **Other** is the quick fix: apply what the user typed at once, change only the fields named, then ask the same question again with the updated list. Several fixes are separated by semicolons (values often contain commas); also accept one fix per line, or commas when the labels make it clear. Ask only if a fix is still unclear.

   **Sections with several entries** (two degrees, three jobs): number each entry with a line of its own (a line "#1", "#2" above its fields), and make the example fix use the numbers: "Wrong? Type fixes under Other: #1 DATES: Sep 2024 – May 2026; #2 GPA: 3.9". Accept the number with or without "#" ("1 DATES: ..."), or the school or company name instead ("Example University DATES: ..."). A fix with a repeated label and no number or name: ask which entry.
   The example fix in the last line fits the section, uses made-up values, stays short enough not to wrap, and never uses the phone number. For Contact: "Wrong? Type fixes under Other: CITY: Newark; EMAIL: name@example.com". Never offer to skip a section: a user who shared a resume wants it read.

   Fields per section:
   - **Contact:** First name, Last name, Email, Phone, City, LinkedIn, GitHub, Website. Split the name into first and last (see "Names" below).
   - **Education:** one block per degree: Degree, School, Location, Dates, GPA (if shown).
   - **Work history:** paid jobs only, from the resume's experience section: one block per job with Title, Company, Location, Dates. Never put projects, coursework, volunteering or research here.
   - **Projects:** one line per project: **Project:** name, then a few words on what it is.
   - **Skills:** grouped as on the resume, for example **Languages:** Python, TypeScript.
   Never replace the field list with a sentence like "your name, email and phone".
   Nothing is saved until the user confirms the section. Fix what the user corrects, and show the corrected row.
   - **Missing fields** (no GitHub, no website, no phone): show the row as "not on resume", never fill it from a guess (not from the name, the email or a web search). Optional fields (GitHub, LinkedIn, website, other links) are always taken from the resume when they are there, but never asked for when they are not: the row stays "not on resume", the user can add one as a fix, and `hayhire:apply` asks only if a form requires it. The fields almost every application form requires (first and last name, email, phone, city) are asked for if missing, with "Skip for now" as an option: `hayhire:apply` then asks when a form needs one. Job search and the tracker need no contact details at all.
   - **Vague fields:** save them as written, without a question. A state instead of a city ("New Jersey") is fine: `hayhire:apply` asks for a city only when a form requires one, and saves it.
   - **Names:** split into first and last only when it is clear: exactly two words in the usual order. Ask (clickable) whenever it is not: more than two words (middle names, two surnames, "de", "van", "bin"), initials, a family-name-first order, all capitals, or a nickname in quotes or brackets. Offer the likely splits as options, for example "First: Ana María / Last: García López" and "First: Ana / Last: María García López", with Other. Never take the name from the email address or the file name.
   - **Typed answers:** check them the same way (a typed GitHub link must look like github.com/<name>; an email must have one @ and a domain); ask again if not.
4. **Ask only what finding the right jobs needs**, a few clickable questions at a time, offering likely options from the resume. Never assume the user is looking in the US. Everything else waits until it is needed (see "Asked later" below). Quick start, in this order:
   - **Goal:** full-time, internship or both; roles in priority order (`multiSelect`, roles suggested from the resume); the most years of experience a posting may ask for.
   - **Where to look** (`multiSelect`): "Where are you looking for jobs?" Build the options from the resume, in this order: 1) the country the user lives in now (from the contact details or the latest job); 2) a wide region, the one most tied to the resume other than that country (for example "Europe (any country)" for someone who worked or studied in Europe); 3) one specific other country from the resume, from past jobs or studies (for example "Portugal"); 4) "Anywhere". Fill a slot the resume gives nothing for with a big job market near the user. Other takes any country, region or city ("Canada", "UK and Ireland", "Singapore", "Latin America").
     Then, for each place picked, one follow-up with `multiSelect`: "Anywhere in <place>" or two or three of its largest job markets as options, Other to type cities. Then remote: "Remote within these places", "Remote anywhere", "No remote". Then which work styles are fine: on-site, hybrid, remote.
   - **Work authorization for the US, only if the places include the US** (the United States, a US city, "Americas", "North America", "Anywhere", or remote that covers the US). Ask: needs US visa sponsorship now / in the future / never; current US status (for example student visa (F-1) with OPT or CPT, work visa (H-1B), permanent resident, citizen, or Other). If no place includes the US, ask nothing about visas or work permits and do not mention them: outside the US, `hayhire:apply` asks when a form needs it. Ask only what forms need; never ask for ID numbers.
   - **Graduation, only for current students:** ask only if the resume shows a degree still in progress (an end date after today, or "expected", "in progress", "present"). Then: is that date certain, or could it move earlier or later? Save it as `GRAD_DATE` (and `ALT_GRAD_DATE` if it could move). If every degree is finished, ask nothing about graduation and leave both empty.
   - **How recent:** "How old can a job posting be?" with "Last 7 days", "Last 14 days", "Last 30 days" (Other for another number). Save it as "Max posting age" in `notes/job-search.md`. Say once that any run can override it ("run a job for 15, last 7 days").
   - **Companies (optional, one question):** any companies to check on every run, or to skip? Options "None for now" and "Add some" (Other to type them).
   - Nothing else. The tracker page is created for the user (step 6), not asked about.
   **Asked later, never at setup:** start date or notice period, willingness to relocate, salary rule, self-identification, cover letters, which browser fills applications and tracker sharing. Never ask about the privacy blocklist (`blocklist.txt`): it is only for people who change and publish HayHire's code, and they fill it in themselves. `hayhire:apply` asks each one the first time a form or the user needs it, and saves the answer. Tracker sharing starts as `private`; say once that the user can change it with "set up job agent".
   **Check typed answers before saving.** Anything typed under "Other" that feeds the search (places, remote regions, role titles):
   - Clean it up: fix typos, add the region and country ("Austin" becomes "Austin, TX, United States", "Munich" becomes "Munich, Germany"), expand regions and nicknames into the places the search looks for ("Bay Area" becomes San Francisco, San Jose, Oakland and Palo Alto; "DACH" becomes Germany, Austria and Switzerland; "NYC" becomes New York, NY; "MLE" becomes Machine Learning Engineer).
   - Never guess when it is unclear: ask with a clickable question ("Portland: Oregon or Maine?", "Cambridge: UK or Massachusetts?").
   - Confirm the final list in priority order with one clickable question ("Your places: 1) Berlin, Germany 2) Remote: Europe 3) Toronto, Canada. Right?"), with "Looks right" or "Change it". The order is the priority: jobs in the first choice come first.
   - Save the places in `notes/job-search.md` under "Places" (in order), and whether the US is among them.
   Apply the same checks whenever the user changes these answers later.
5. Write each answer where the questionnaire's table says: `config.json`, `apply/profile.md` (format of `${CLAUDE_PLUGIN_ROOT}/examples/profile.example.md`), `cover-letter/facts.json` (format of `${CLAUDE_PLUGIN_ROOT}/examples/facts.example.json`), `notes/job-search.md`. Read each file before writing; never overwrite an existing answer without showing the old and new value and asking. Never ask for or store passwords, ID numbers or bank details. Keep every file in `private/` readable only by the user (`chmod 600`).
6. **Tracker: always create it, never ask and never skip.** Every other skill saves to this page, so setup is not finished without it: do not offer to skip or postpone it, and do not ask where to build it. If `TRACKER_URL` in `config.json` is empty or still the example (`<your-tracker-id>`), create the page: copy `${CLAUDE_PLUGIN_ROOT}/tracker/tracker.html` to `<PRIVATE_DIR>/tracker/tracker.html`, replace both `{{TRACKER_NAME}}` with "<First name>'s Jobs" (also saved as `TRACKER_NAME`) and `{{SHOW_OUTREACH}}` with `false` (`true` only if `OUTREACH` in `config.json` is `true`; recruiter outreach is not part of HayHire yet, so never mention it), and publish that copy with the Artifact tool: `icon` "briefcase", `description` "Job search tracker made by HayHire", `capabilities` `{"db": {}, "user": {}}` (load the `artifact-capabilities` skill first if the tool asks). It starts private: only the user can open it. Save the new link as `TRACKER_URL` and give it to the user as a clickable link: "Your tracker is ready (private, only you can open it): [<First name>'s Jobs](<TRACKER_URL>)". If publishing fails, say why, try once more, and if it still fails, stop setup there and say it must be fixed before job search can run; never carry on without a tracker. If the user already has a HayHire tracker and gives its link, use that instead. Set `TRACKER_SHARING` to `private` without asking. **Changing tracker sharing later** (when the user asks): ask who may see the tracker's data when its link is shared, and save the answer as `TRACKER_SHARING` in `config.json`. It is the user's choice: explain what each level shows, then do what they pick. Apply it as the page's `db` access rules (`read` levels; writes stay with the owner):

   | `TRACKER_SHARING` | `jobs` | `email_applications` | `recruiter_outreach` |
   |---|---|---|---|
   | `private` | owner | owner | owner |
   | `applications` | view | view | owner |
   | `everything` | view | view | view |

   For example `applications` is `rules: [{path: "jobs", read: "view", write: "owner"}, {path: "email_applications", read: "view", write: "owner"}, {path: "recruiter_outreach", read: "owner", write: "owner"}]`. Rules cover whole collections, not single fields, so say plainly what a level exposes: history rows hold the Gmail account address and a Gmail link (the link only opens for someone signed in to that mailbox), and outreach rows name companies the user emailed (mention outreach only if `OUTREACH` is `true`). Sharing the link (the Share menu) and these rules are separate: a viewer sees the page, but only the data the rules allow. When the user changes the level later, update both the config and the page's rules.
7. **Browser for applying: not at setup.** `hayhire:apply` runs this step the first time the user applies (or when they ask to change it). Save the answer as `APPLY_BROWSER` in `config.json`: `chrome`, `built-in` or `none`.
   - First note, silently, whether the built-in browser is available: tools named `mcp__Claude_Browser__*` are present (the Claude desktop app). Do not check for the Chrome extension yet, and do not ask about it.
   - Then ask one clickable question, "Where should applications be filled in?", never "which browser do you use". Two options:
     - **Chrome with the Claude extension**: "Fills the whole form and attaches your resume and cover letter. Needs Google Chrome and the free Claude in Chrome extension."
     - **Claude's built-in browser**: "Nothing to install. Fills the form; you attach your resume and cover letter yourself (the agent says which file goes where)." Offer it only if the built-in browser is available.
     If only one of them is available, still ask, with the other as "Set up later" ("Skip applying for now; job search and tracking still work").
   - **Chrome picked:** only now check for the extension. If tools named `mcp__claude-in-chrome__*` (or a single `enable__mcp__claude-in-chrome` tool) are present, ask (clickable) "May I check whether the Claude in Chrome extension is connected? It only lists connected browsers; nothing is opened.", then call `list_connected_browsers`. A listed browser means it is installed and connected. Never ask this when the user picked the built-in browser.
   - **Chrome picked, extension connected:** set `chrome`, ask the user to name this computer's browser, and save its name and device id in `browsers.json` (see "Browser safety" in the `hayhire:search` skill).
   - **Chrome picked, extension not found:** set `chrome` and give the steps: install Claude in Chrome from https://claude.com/chrome, sign in with the same Claude account, connect it, then say "set up job agent" again to name the browser. Until it is connected, `apply` stops and says it is waiting for the extension.
   - **Built-in picked:** set `built-in`.
   - **Neither available** (for example the terminal without the desktop app): set `none` and tell the user plainly that automatic applying does not work here. Everything else still works: job search, cover letters, the tracker and email tracking. Run setup again once a browser is available.
8. Finish with a summary of what was saved, the tracker link again (clickable), what is still missing, and the first command to try: "run a job for 5". Mention that typing **help** lists every command, and once that other resume versions (for example one for ML roles) can be added any time with "update my resume".

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
2. Run `sh ${CLAUDE_PLUGIN_ROOT}/backup.sh`. It packs `private/` (with that export), the email tracking state and settings into `~/hayhire-backups/hayhire-backup-<date>.tar.gz`, readable only by the user. Gmail login tokens are left out on purpose.
3. Report the archive path and the row counts. Remind the user the archive holds personal data: keep it on this computer, never in a repo.

## Uninstall ("uninstall hayhire" or "uninstall job agent")

1. Ask with one clickable dialog: back up first (yes, recommended / no); the tracker page (keep it / delete it after the backup); the data folder, the parent of `<PRIVATE_DIR>` (keep it / move it to the Trash).
2. If backing up, do "Back up" above and stop if it fails.
3. If the user chose to delete the tracker page, delete it with the Artifact tool only after the backup succeeded (they confirm the delete).
4. Run `sh ${CLAUDE_PLUGIN_ROOT}/uninstall.sh --no-backup` plus `--delete-folder` or `--keep-folder`. It removes the private-folder link and links left by older installs (only links into a HayHire copy). With `--delete-folder` it moves the data folder to the Trash only if it holds nothing but HayHire's parts (`private`, `public`, `email_fetcher`); otherwise it moves just `private/` and says what it left. Last, it uninstalls the plugin if it came from the marketplace (`claude plugin uninstall hayhire@hayhire`).
5. If the script says the plugin is still installed (the `claude` command was not found), tell the user to remove it with `/plugin` (Installed tab, HayHire, Uninstall) or `claude plugin uninstall hayhire@hayhire`. This chat keeps the skills until it is restarted.
6. Tell the user what is left for them: removing Gmail access at https://myaccount.google.com/permissions, and this project's Claude Code memory in `~/.claude/projects/` (offer to delete that folder; ask first). To set up again: install the plugin, then say "restore my job data".

## Restore ("restore my job data")

1. List the archives in `~/hayhire-backups/`, newest first, and ask (clickable) which one. Extract it into a new temporary folder; never extract straight over existing files.
2. **Private files:** copy each file into `<PRIVATE_DIR>`. Where the current file is still the example from `${CLAUDE_PLUGIN_ROOT}/examples/`, replace it; where it has the user's own answers, show what differs and ask. Keep `chmod 700` on folders and `600` on files.
3. **Email tracking:** if `<EMAIL_FETCHER_DIR>` exists, copy back `settings.json`, `credentials.json` and `data/` (ask before replacing anything already there). Gmail needs a fresh sign-in, because tokens are not backed up.
4. **Tracker:** the old page may be gone. Ask (clickable) whether to use the current tracker or create a new one (as in step 6 of setup), and set `TRACKER_URL` in `config.json`. List its collections first: if they already have rows, ask before adding, and never overwrite a row with the same id without asking. Write the rows from `backup/tracker/*.json` with ArtifactData `batch`, keeping their ids. Apply the `TRACKER_SHARING` rules (step 6 of setup).
5. **Local copy for the email sync:** the restored rows have new versions, so refresh the local copy as in step 6 of the `hayhire:sync` skill (`data/sync/mirror/` and `data/sync/versions.json`, and the same for outreach). Then `sync_prepare.py` must plan 0 writes.
6. Report the counts restored per collection, and run setup only for anything still missing. Delete the temporary folder.
