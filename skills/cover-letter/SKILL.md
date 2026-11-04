---
name: cover-letter
description: Generate a tailored one-page cover letter PDF for a specific job posting in the user's fixed layout, saved to <JOBS_DIR>/cover_letters. Use when the user asks for a cover letter for a job, or when an application form needs a cover letter upload.
---

# Cover Letter Generator

## Setup (read first)

1. Read `~/.claude/job-agent-private/config.json` (a link to the `private` folder next to this repo, made by `install.sh`). Every `<NAME>` placeholder in this skill is a value from it (`<TRACKER_URL>`, `<PRIVATE_DIR>`, `<JOBS_DIR>`, ...). Stop and ask if it is missing.
2. Read `<PRIVATE_DIR>/notes/cover-letter.md` if it exists: the user's own rules for this skill. They add to this file and win where they disagree.

Produces a PDF in a fixed layout: header, contact bar, "Cover Letter" heading. Personal details and the fixed paragraphs come from `<PRIVATE_DIR>/cover-letter/facts.json` (see `examples/facts.example.json` in the repo). Only a few parts change per job.

## What changes per job

1. **Date** (top right): today's date, e.g. `October 12, 2026`. Filled automatically.
2. **RE line**: the exact job title from the posting, in **bold** (e.g. `Software Engineer Intern - Austin, TX`).
3. **Paragraph 1**: only the position and company change.
   - Template: the `intro` in `facts.json`, with `{short_title}`, `{company}` and `{mission}` filled in.
   - `short_title` is a natural short form of the title (e.g. "Software Engineering Intern"). `mission` is a phrase from the company's own materials (mission, product or initiative), completing "has toward ...". Take it from the job posting or the company's site; do not invent it.
4. **Paragraph 3**: skills and experience tailored to the job. Start from this structure and adapt it:
   - Write it from the resume, choosing the real skills that match the posting.
   - Add a personal tie to the company (a product the user actually uses, etc.) only if it is true.

- Avoid repeating the company name close together. Name the company once in the closing sentence of paragraph 3 (e.g. "contribute to the engineering team and help build resilient solutions for Acme").

## What never changes

The header, "Dear Hiring Team,", **paragraph 2** (the `experience` paragraph in `facts.json`), the last paragraph ("I would love the opportunity ..."), and the signature. Do not edit these.

## Honesty rules

- Use only facts from the user's resume and website. Do not invent experience, skills, products used, or numbers.
- Tailor by choosing which of the user's real skills to emphasize (matching the posting's requirements), not by adding new ones.
- When mentioning the reinforcement learning project, say "reinforcement learning model"; do not mention the Deep Q-network.
- Keep it to one page.

## How to generate

1. Write a JSON file with these keys:
   - `title`: exact title from the posting
   - `short_title`: short natural title for paragraph 1
   - `company`: company name
   - `mission`: phrase completing "...has toward ..."
   - `para3`: the full text of paragraph 3
   - `date`: optional; defaults to today
2. Run: `python3 <SKILLS_DIR>/cover-letter/make_cover_letter.py job.json`
   (needs Google Chrome installed; it prints the PDF path; an internet connection loads the Carlito font).
3. Open the PDF and check it: one page, bold RE title, no leftover `{{...}}` placeholders, company name spelled correctly everywhere.
4. Tell the user the file path and show them paragraphs 1 and 3 for review before it is uploaded anywhere.

## File naming

`<Name>_Cover_Letter_<Position>_<Company>.pdf`, words separated by underscores.
- Position: the job title with the location after " - " removed, parentheses and punctuation removed, and "Software Engineer" shortened to "Swe". Example: `Software Engineer Intern - Austin, TX` becomes `Swe_Intern`.
- The company name is always added at the end. Example: `Alex_Rivera_Cover_Letter_Swe_Intern_Acme.pdf`.
- If a file with that name exists, `_2`, `_3` is appended. Never overwrite an existing letter.

## Header details

The contact bar comes from `facts.json`: email, phone, website, LinkedIn and location.
