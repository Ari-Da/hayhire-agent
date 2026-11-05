# Setup questionnaire

The `job-agent-setup` skill asks these questions in small batches and writes the answers into your `private/` folder. Nothing in this repo is pre-filled with anyone's data. Never give passwords, ID numbers or bank details: the agent never asks for them and never types them.

| Answers go to | Used by |
|---|---|
| `private/config.json` | every skill (tracker link, folders, browser) |
| `private/apply/profile.md` | `apply`, `job-search` (form answers, eligibility) |
| `private/cover-letter/facts.json` | `cover-letter` (header and fixed paragraphs) |
| `private/notes/job-search.md` | `job-search` (your roles, locations, companies) |
| `private/jobs/resume/` | `apply` (files to upload) |

**Quick start** (about 10 minutes): A1, A2, A3, A5, B1 to B4, D1, D2. The rest can wait: `apply` asks when a form needs something missing and saves the answer.

## A. About you (every application)

1. **Contact:** legal name, preferred name, email, phone, city and country, LinkedIn, GitHub, website. If a form has one links field, which link goes there?
2. **Work authorization:** which countries? Do you need sponsorship **now**? In the **future**? Does student work permission count as sponsorship for you?
3. **Education:** for each degree, school, degree, field, dates, GPA. Is your graduation date certain? If not, what are the scenarios?
4. **Work history:** for each job, employer, title, dates and 3 to 5 true bullets. Anything you do **not** want claimed?
5. **Skills and files:** skills you can honestly claim, and the exact names to pick in dropdowns. Where are your resume versions, and when is each one used?
6. **Standard answers:** salary rule, earliest start date, relocation, preferred offices in order, "how did you hear about us".
7. **Self-identification:** gender, ethnicity, veteran and disability answers, or "decline". What to do when a form has no decline option?

## B. Your search (drives `job-search`)

1. **Goal:** full-time, internship or both, and in what order? How many internships per run, and under what conditions?
2. **Roles in priority order** (for example: 1) ML engineer 2) software engineer), plus titles you never want.
3. **Level:** the most years of experience a posting may ask for; level labels that count as entry level for you (new grad, I/II, associate).
4. **Location:** countries and cities in order; remote, hybrid or on-site?
5. **Companies:** companies to check every run, and companies to skip.
6. **Run size:** default number of jobs per run, and how old a posting may be (default 14 days).

## C. Cover letters (optional)

Skip this part if no cover letters are wanted. The `apply` skill only writes one when a form has a cover letter field, and leaves that field empty when this part is skipped.

1. **Voice:** formal, warm or concise; words to avoid.
2. **Fixed parts:** the opening template (with `{{SHORT_TITLE}}`, `{{COMPANY}}`, `{{MISSION}}`), the experience paragraph, the closing. The agent can draft these from part A for your approval.
3. **Honesty:** companies or products you really use, so a personal tie is only ever true.

## D. Setup and guardrails

1. **Tracker:** create a Claude artifact for your jobs and paste its link.
2. **Tracker sharing:** who may see its data when you share the link? `private` (the default: only you), `applications` (jobs, application history and charts; recruiter outreach stays yours) or `everything`. See [Sharing the tracker](../README.md#sharing-the-tracker). You can change it at any time.
3. **Browser:** connect Claude in Chrome and name this computer's browser; the agent only ever uses that one.
4. **Email tracking (optional):** which Gmail accounts hold your application emails? This is set up in `email_fetcher`, read-only.
5. **Privacy check:** list words that must never be published (your name, emails, past employers). They go into `private/blocklist.txt`.
