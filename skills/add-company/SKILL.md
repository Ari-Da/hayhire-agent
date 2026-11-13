---
name: add-company
description: "HayHire: Add a company to the list checked on every job run (after finding and testing its job board), remove one from that list, or skip a company on every run. Use when the user says \"add company <name>\", \"add <name> to my search\", \"check <name> every run\", \"remove company <name>\", \"skip company <name>\" or \"/hayhire:add-company <name>\"."
---

# Add a company to every run

## Setup (read first)

1. Read `~/.claude/job-agent-private/config.json` (a link to the user's private folder, made by the `hayhire:setup` skill). Every `<NAME>` placeholder in this skill is a value from it (`<PRIVATE_DIR>`, ...). If it is missing, HayHire is not set up yet: offer to run `hayhire:setup`.
2. The list lives in `<PRIVATE_DIR>/notes/job-search.md`, which `hayhire:search` reads on every run: companies under "Companies checked every run" are searched on every normal run, and companies under "Companies to skip" are left out of every run.

This is not a job run: do not search for jobs or write to the tracker.

## Input

- The company name, optionally with a careers link or a note (`add company Stripe, NYC only`, `/hayhire:add-company Stripe https://stripe.com/jobs`).
- No name given: ask for it in one line.

## "add company <name>"

1. Read the "Companies checked every run" section of `<PRIVATE_DIR>/notes/job-search.md` (create the heading at the end of the file if it is missing). If the company is already there, or on `${CLAUDE_PLUGIN_ROOT}/skills/search/sponsor_companies.csv` at Tier 0 (already checked every run), say so and stop. If it is on the CSV at another tier, add it anyway (other tiers are not checked every run). If it is under "Companies to skip", ask before moving it.
2. Find how to read its openings, cheapest first: a public ATS board (Greenhouse `boards-api.greenhouse.io/v1/boards/<board>/jobs`, Ashby `api.ashbyhq.com/posting-api/job-board/<board>`, Lever `api.lever.co/v0/postings/<board>`, Workday `<host>/wday/cxs/<tenant>/<site>/jobs`), else a JSON API behind its careers site, else the careers page in the browser (`<APPLY_BROWSER>`; with `none`, web fetch only). Use a link the user gave first. If two companies match the name, ask which one (clickable).
3. Fetch the board once to confirm it works, and note: how many postings, which field holds the original posting date, the link format for a job and where its job ID is (path or query parameter), main locations, and whether postings mention visa sponsorship (only when the user needs US sponsorship, per `<PRIVATE_DIR>/apply/profile.md`).
4. Append one bullet in the same style as the existing entries: `- **<Company>** (user request, <Mon D, YYYY>; checked every run): what it does, the board and its URL (which date field to use; link format; which value to store as jobId, especially when the ID is only in a query parameter such as ?gh_jid=), locations and how to count them against the user's places, the sponsorship wording to record, which role types to list or skip, and any note the user gave.`
5. Tell the user in two or three lines what was added (board, number of open postings, anything notable such as "all roles senior" or "no roles in your places right now"), and that the next "run a job" checks it. Do not list its jobs now unless they ask; if they do, run `hayhire:search` limited to that company.

## "remove company <name>"

Delete its bullet from "Companies checked every run" (match the name loosely, ignoring "Inc", "LLC"). If it is not there, say so. Show the removed line in the reply.

## "skip company <name>"

Add `- **<Company>** (user request, <Mon D, YYYY>): <reason, if given>` under a "Companies to skip" heading in the same file (create it if missing), and remove it from "Companies checked every run" if it is there. Every run then leaves it out.

## Guardrails

- Edit only the user's private notes, never the public skill files: never change `sponsor_companies.csv` or any skill for a user's company request.
- Only read job boards; never apply, sign in or create accounts.
