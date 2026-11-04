---
name: job-agent-setup
description: First-time setup of the job agent - ask the setup questionnaire and write the answers to the private folder. Use when the user says "set up job agent", "job agent setup", or wants to change their profile, search preferences or cover letter facts.
---

# Job agent setup

1. Find the private folder: `~/.claude/job-agent-private` (made by `install.sh`). If it is missing, ask the user to run `./install.sh` from the repo first.
2. Read `docs/setup-questionnaire.md` in the repo (this skill's folder is `<repo>/skills/job-agent-setup`). Ask the **Quick start** questions first, a few at a time, in plain words. Offer the rest afterwards.
3. Write each answer where the questionnaire's table says: `config.json`, `apply/profile.md` (format of `examples/profile.example.md`), `cover-letter/facts.json` (format of `examples/facts.example.json`), `notes/job-search.md`. Read each file before writing; never overwrite an existing answer without showing the old and new value and asking.
4. Never ask for or store passwords, ID numbers or bank details. Keep every file in `private/` readable only by the user (`chmod 600`).
5. Finish with a summary of what was saved, what is still missing, and the first command to try: "run a job for 5".
