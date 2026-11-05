---
name: job-agent-setup
description: First-time setup of the job agent - ask the setup questionnaire and write the answers to the private folder. Use when the user says "set up job agent", "job agent setup", or wants to change their profile, search preferences or cover letter facts.
---

# Job agent setup

1. Find the private folder: `~/.claude/job-agent-private` (made by `install.sh`). If it is missing, ask the user to run `./install.sh` from the repo first.
2. Read `docs/setup-questionnaire.md` in the repo (this skill's folder is `<repo>/skills/job-agent-setup`). Ask the **Quick start** questions first, a few at a time, in plain words. Offer the rest afterwards.
3. Write each answer where the questionnaire's table says: `config.json`, `apply/profile.md` (format of `examples/profile.example.md`), `cover-letter/facts.json` (format of `examples/facts.example.json`), `notes/job-search.md`. Read each file before writing; never overwrite an existing answer without showing the old and new value and asking.
4. Never ask for or store passwords, ID numbers or bank details. Keep every file in `private/` readable only by the user (`chmod 600`).
5. **Tracker sharing.** Ask who may see the tracker's data when its link is shared, and save the answer as `TRACKER_SHARING` in `config.json` (default `private`). It is the user's choice: explain what each level shows, then do what they pick. Apply it as the page's `db` access rules (`read` levels; writes stay with the owner):

   | `TRACKER_SHARING` | `jobs` | `email_applications` | `recruiter_outreach` |
   |---|---|---|---|
   | `private` | owner | owner | owner |
   | `applications` | view | view | owner |
   | `everything` | view | view | view |

   For example `applications` is `rules: [{path: "jobs", read: "view", write: "owner"}, {path: "email_applications", read: "view", write: "owner"}, {path: "recruiter_outreach", read: "owner", write: "owner"}]`. Rules cover whole collections, not single fields, so say plainly what a level exposes: history rows hold the Gmail account address and a Gmail link (the link only opens for someone signed in to that mailbox), and outreach rows name companies the user emailed. Sharing the link (the Share menu) and these rules are separate: a viewer sees the page, but only the data the rules allow. When the user changes the level later, update both the config and the page's rules.
6. **Browser for applying.** Save the answer as `APPLY_BROWSER` in `config.json`: `chrome`, `built-in` or `none`.
   - First check what this session can use, without opening anything:
     - **Claude in Chrome:** tools named `mcp__claude-in-chrome__*` (or a single `enable__mcp__claude-in-chrome` tool) are present. If they are, ask permission, then call `list_connected_browsers`. A listed browser means the extension is installed and connected.
     - **Built-in browser:** tools named `mcp__Claude_Browser__*` are present (the Claude desktop app).
   - **Extension connected:** say so, and ask whether to apply there. If yes, set `chrome`, ask the user to name this computer's browser, and save its name and device id in `browsers.json` (see "Browser safety" in the `job-search` skill). The `apply` skill then fills whole forms, uploads included.
   - Ask which browser the user normally uses. The extension runs in Google Chrome; Edge and other Chromium browsers (Brave, Arc, Vivaldi, Opera) may work through Claude Code but are not officially supported. Firefox and Safari have no Claude extension: recommend `built-in`.
   - **Extension not found:** do not push it. Offer `built-in` if it is available, and explain the trade-off: the agent fills the form, and the user uploads the resume and cover letter. If the user still wants their own browser, set `chrome` and give the steps: install Claude in Chrome from https://claude.com/chrome, sign in with the same Claude account, connect it, then say "set up job agent" again to name the browser. Until it is connected, `apply` stops and says it is waiting for the extension.
   - **Neither available** (for example the terminal without the desktop app): set `none` and tell the user plainly that automatic applying does not work here. Everything else still works: job search, cover letters, the tracker and email tracking. Run setup again once a browser is available.
7. Finish with a summary of what was saved, what is still missing, and the first command to try: "run a job for 5".
