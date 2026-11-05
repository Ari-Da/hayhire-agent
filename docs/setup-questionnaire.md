# Setup questionnaire

The `job-agent-setup` skill starts by reading your resume and filling in everything it shows: contact details, education, work history and skills. You confirm or fix that, then answer the rest as clickable questions in the chat, a few at a time. Topics marked 📄 come mostly from the resume. Answers are written into your `private/` folder. Nothing in this repo is pre-filled with anyone's data. Never give passwords, ID numbers or bank details: the agent never asks for them and never types them.

| Answers go to | Used by |
|---|---|
| `private/config.json` | every skill (tracker link, folders, browser) |
| `private/apply/profile.md` | `apply`, `job-search` (form answers, eligibility) |
| `private/cover-letter/facts.json` | `cover-letter` (header and fixed paragraphs) |
| `private/notes/job-search.md` | `job-search` (your roles, locations, companies) |
| `private/jobs/resume/` | `apply` (files to upload) |

**Quick start** (about 5 minutes with a resume): confirm A1, A3, A4 and A5 from the resume, then answer A2, B1 to B4, D1, D2, D3.

**New resume later?** Say "update my resume" and share the file. The agent keeps the old one in `resume/archive/`, shows what changed (a new job, new skills) and updates your answers after you confirm. The rest can wait: `apply` asks when a form needs something missing and saves the answer.

## A. About you (every application)

1. 📄 **Contact:** legal name, preferred name, email, phone, city and country, LinkedIn, GitHub, website. If a form has one links field, which link goes there?
2. **Work authorization:** which countries? Do you need sponsorship **now**? In the **future**? Does student work permission count as sponsorship for you?
3. 📄 **Education:** for each degree, school, degree, field, dates, GPA. Is your graduation date certain? If not, what are the scenarios?
4. 📄 **Work history:** for each job, employer, title, dates and 3 to 5 true bullets. Anything you do **not** want claimed?
5. 📄 **Skills and files:** skills you can honestly claim, and the exact names to pick in dropdowns. Where are your resume versions, and when is each one used?
6. **Standard answers:** salary rule (optional: by default `apply` suggests a figure for each job from its posted range, its location and your experience, and explains it; set your own rule, such as a floor, if you prefer), earliest start date, relocation, preferred offices in order, "how did you hear about us".
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
3. **Browser for applying:** your own Chrome with the Claude in Chrome extension (`chrome`: fills everything, resume and cover letter uploads included), or the Claude app's built-in browser (`built-in`: fills the form, but you upload the resume and cover letter yourself). Setup checks whether the extension is already connected before asking. The extension runs in Chrome (Edge and other Chromium browsers may work, unofficially); Firefox and Safari have none, so their users pick `built-in`. If neither is available, automatic applying is off (`none`) and the rest still works. With `chrome`, name this computer's browser; the agent only ever uses that one.
4. **Email tracking (optional):** which Gmail accounts hold your application emails? This is set up in `email_fetcher`, read-only.
5. **Privacy check:** list words that must never be published (your name, emails, past employers). They go into `private/blocklist.txt`.
