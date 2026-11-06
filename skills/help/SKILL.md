---
name: help
description: "HayHire: List every HayHire command with a one-line explanation. Use when the user types \"help\", \"hayhire help\", \"/hayhire:help\", \"commands\" or \"what can you do\" while using HayHire."
---

# HayHire help

Reply with the list below exactly as it is (markdown headings and tables, not a code block: long lines in a code block wrap and jumble the columns). Do not run anything, read any file or call any tool first.

If the user asks about one command ("help apply"), show only that command's row, then two or three sentences on what it does and what it needs.

## HayHire commands

Say any command in plain words, or type its shortcut.

### Setup

| Command | What it does | Shortcut |
|---|---|---|
| `set up job agent` | First-time setup: reads your resume, asks a few questions, creates your private tracker page | `/hayhire:setup` |
| `update my resume` | Replace your resume or add another version | |
| `change my search` | Change roles, places, or how recent postings must be | |
| `change tracker sharing` | Choose who can see your tracker's data (private by default) | |

### Find jobs

| Command | What it does | Shortcut |
|---|---|---|
| `run a job for 15` | Find up to 15 new, verified jobs | `/hayhire:search 15` |
| `run a job for 20, last 7 days` | Up to 20 jobs posted in the last 7 days | `/hayhire:search 20 7` |
| `job run startup 10` | Y Combinator startups (US) that sponsor visas | |

### Apply

| Command | What it does | Shortcut |
|---|---|---|
| `apply to 1104-02` | Fill job 1104-02 in your browser and stop before Submit | `/hayhire:apply 1104-02` |
| `submitted` | Record the application you just sent | |
| `cover letter for 1104-02` | Write a one-page cover letter | `/hayhire:cover-letter` |

### Track

| Command | What it does | Shortcut |
|---|---|---|
| `update history` | Read your application emails and update the history | `/hayhire:sync` |
| `update outreach` | Refresh recruiter outreach stats | |
| `pipeline status` | Where everything stands, and what to do next | `/hayhire:pipeline` |

### Your data

| Command | What it does | Shortcut |
|---|---|---|
| `back up my job data` | Save your tracker rows and private files to ~/hayhire-backups | |
| `restore my job data` | Bring a backup back | |
| `uninstall hayhire` | Optional backup, then remove HayHire | |

### Help

| Command | What it does | Shortcut |
|---|---|---|
| `help` | This list | `/hayhire:help` |
| `help <command>` | More about one command, e.g. `help apply` | |

You always click Submit yourself; HayHire never submits an application. If another job tool answers instead, start with "hayhire" ("hayhire, apply to 1104-02").
