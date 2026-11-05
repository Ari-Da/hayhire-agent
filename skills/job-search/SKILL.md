---
name: job-search
description: Search the web for US entry-level full-time jobs (priority) and internships in AI/ML Engineering, Software Engineering, Full-stack, Frontend, and Backend, verify each posting is still open on the company's own careers page, and save the results to the tracker page. When the user says the run is for another person, instead search data engineer / data analyst roles (preferably outside the US, Europe first) and save them to that person's tracker. Use when the user asks to find jobs, internships, or run a job search (for the user by default, or for a second person set up in the private notes).
---

# Job Search (US only)

## Setup (read first)

1. Read `~/.claude/job-agent-private/config.json` (a link to the `private` folder next to this repo, made by `install.sh`). Every `<NAME>` placeholder in this skill is a value from it (`<TRACKER_URL>`, `<PRIVATE_DIR>`, `<JOBS_DIR>`, ...). Stop and ask if it is missing.
2. Read `<PRIVATE_DIR>/notes/job-search.md` if it exists: the user's own rules for this skill. They add to this file and win where they disagree.

## Startup run

- **Trigger:** only when the user says "job run startup", "startup run" or similar. A normal job run ("run a job for 10", etc.) is unchanged and never searches YC. A startup run searches the Y Combinator startup directory **only** (no SimplifyJobs, ATS scans, LinkedIn or the every-run company list). Results still go to the tracker page, deduped against all existing rows.
- **Source:** https://www.ycombinator.com/companies?isHiring=true&regions=United%20States%20of%20America (5,000+ hiring US companies). Work in the built-in browser tab; curl to YC's search backend is blocked, so do not call its Algolia API directly.
  1. YC job board pages carry all postings as JSON in the `data-page` attribute (`props.jobPostings`): fetch `/jobs/role/software-engineer`, `/jobs/role/software-engineer/<new-york|san-francisco|seattle|chicago|boston|austin|los-angeles|remote>` and `/jobs/role/science` plus the same cities, from inside a ycombinator.com tab with `fetch()` (about 50 jobs each).
  2. Then the directory: open the URL above (recent batches first, e.g. add `&batch=Fall%202026&batch=Summer%202026&batch=Spring%202026&batch=Winter%202026`), scroll with real scroll actions (JS scrolling does not load more; 40 companies per load), collect `/companies/<slug>` links, and fetch each `/companies/<slug>/jobs` page (same `data-page` JSON), 4 at a time with short pauses.
- **Fields per posting:** `visa` ("Will sponsor", "US citizen/visa only", "US citizenship/visa not required"), `minExperience` ("Any (new grads ok)", "1+ years" ...), `role` (`eng`, `science`), `roleSpecificType`, `type`, `location`, `salaryRange`, `createdAt` (relative age). The original posting date is `datePosted` in the job page's `application/ld+json`; always confirm it there.
- **Filters:** `visa` = "Will sponsor" (or the description explicitly offers sponsorship). Skip "US citizen/visa only". "US citizenship/visa not required" is ambiguous: include only if few others qualify, with `sponsorship` = `Unknown` and a note. Full-time, `role` eng or science (skip hardware, electrical, mechanical, DevRel), `minExperience` of Any/1+/2+/3+, US location. Max 2 per company.
- **Window:** posted within **30 days** by default for startup runs (YC sponsoring roles are sparse: on Nov 4, 2026 only 3 qualified within 14 days across ~300 companies). A number the user gives overrides it.
- **Tracker fields:** ids `r<MMDD>s-<NN>-<company>`, `run` `MM_DD_s`, `url` = the YC job page, `boardUrl` = the directory URL, `source` = "YC startup directory (startup run); verified on YC job page", `jobId` = the YC short id. Notes: YC batch, what the company does, years, pay, and the visa wording.

## Input

- `max_posts` (optional integer): the maximum number of job rows to return in this run. **Default: 20.** Read it from the user's invocation (e.g. "run job-search 30", "job search, max 10 posts", `/job-search 15`). If the user gives no number, use 20.
- `max_age_days` (optional integer): the oldest allowed posting date. **Default: 14.** Read it as a second number in the invocation (e.g. `/job-search 20 7` = up to 20 jobs posted in the last 7 days). A job qualifies only if its **original posting date** is no more than `max_age_days` before the run date (today). No exceptions for Summer 2027 or other start dates.
  - Use the original posted/published date: Ashby `publishedAt`, Workday `startDate`, Amazon `posted_date`, Microsoft/Meta "Date posted", Greenhouse `first_published` when present. Greenhouse `updated_at` and SimplifyJobs "Age" are only hints, not the posting date; confirm on the company's posting before including.
  - If a posting's date cannot be found, leave it out and count it in the summary ("N skipped, date unknown").
  - If fewer than `max_posts` jobs fit the window, return fewer and say so. Never reach back to older postings to fill the list.
- Per-company cap: include at most **2 roles per company** in a run, for company variety (Amazon and its subsidiaries together count as one company and keep the stricter cap of **1**, set Oct 18, 2026). Choose the two best fits per company (AI/ML and full-stack first, preferred cities first). Fill the remaining slots from other companies and sources; if nothing else qualifies, return fewer rather than exceed the cap.
- The cap counts only rows that pass every check below (US, sponsorship, graduation rule, verified open on the company site). Never pad the output with unverified or ineligible rows to reach the number; returning fewer is fine, and say so.
- Mix: focus on full-time entry-level roles. Include at most 1 or 2 internships per run, and only if the posting explicitly states the company is willing to sponsor (not merely silent about it). If no internship states sponsorship, include none and fill the whole run with full-time roles.

## Candidate profile (apply to every decision)

- Read the candidate's facts from `<PRIVATE_DIR>/apply/profile.md` (see `examples/profile.example.md` in the repo): degree, graduation date and work authorization. Below, `<GRAD_DATE>` is the planned graduation, `<ALT_GRAD_DATE>` a possible later one, and `<INTERN_YEAR>` the internship year, all from `config.json`.
- The sponsorship rules below apply when the profile says the candidate needs visa sponsorship now or in the future. Skip them if it does not.
- Degree: exclude roles and internships restricted to a different degree level than the candidate's (e.g. undergraduate-only internships for a graduate student, PhD-only roles for a Master's student). For new-grad roles, a Bachelor's requirement is fine if a higher degree counts or the posting says "or equivalent/higher".
- Expected graduation: **<GRAD_DATE>**. Open to full-time roles starting after graduation.
- US-located roles only (remote-US is fine if the employer is US-based and hires in the US). Exclude roles outside the US.

## Targets

**Primary focus: AI/ML roles.** The user mainly wants AI/ML engineering work: AI Engineer, Machine Learning Engineer, Applied AI / Applied ML Engineer, LLM / GenAI Engineer, ML Platform / MLOps Engineer, Research Engineer, Data Scientist or Applied Scientist (when the requirements fit an entry-level or Master's candidate), and Data Engineer roles that feed ML. Search for these first and fill the list with them before general software roles.

**Secondary: general software roles.** Software Engineer, Full-Stack, Frontend, Backend, Software Developer, Member of Technical Staff.

### Level rules (do not require "new grad" in the title)
- Roles labeled new grad, early career, university graduate, entry level or associate are the **top priority** within each focus area.
- Also include **level I or II** roles even when the title says neither new grad nor early career: "Software Engineer I/II", "Engineer 1/2", "SDE I/II", "ML Engineer I/II", "Applied Scientist I" and similar. Adjust to the candidate's real experience.
- Many big companies do not put a level in the title. Judge by the posting's requirements: include the role when it asks for **about 3 years of experience or less** (or none) and a Bachelor's or Master's degree. Exclude Senior, Staff, Principal, Lead, Manager, III and above (unless the company's own scale makes that level entry, e.g. Google's "Software Engineer II" is its entry level), and anything requiring 4+ years.
- Company-specific entry levels: Amazon SDE I/II (and unlabeled "Software Development Engineer" with no required years); Microsoft "Software Engineer" (IC2) and "Software Engineer II" (IC3); Google "Software Engineer II"; Meta E3-E4 (titles have no level, so read the years required); Walmart "Software Engineer I/II"; Apple, Salesforce, Adobe and others: check required years.

### Big-company coverage
Always search the big companies' own sites, not only job-board lists, because their entry roles often lack "new grad" in the title: Amazon (and Audible, Twitch, Ring, Annapurna Labs; see the Amazon note below), Microsoft, Meta, Google, Apple, NVIDIA, Walmart (Workday site `walmart.wd504.myworkdayjobs.com`, site `WalmartExternal`), Salesforce, Adobe, Oracle, Cisco, Intuit, LinkedIn, Uber, PayPal, plus the AI labs (OpenAI, Anthropic). Query each for AI/ML terms first ("machine learning", "applied scientist", "AI engineer", "LLM", "generative AI"), then for software engineer I/II.

### Priority order for ranking (and for filling the cap)
1. AI/ML roles at Tier 0 companies, then at Tier 1 and other companies.
2. AI/ML roles that are labeled new grad / early career, ahead of level I/II roles with no label.
3. Software roles at Tier 0 and Tier 1 companies (labeled new grad / early career first, then level I/II).
4. Everything else that passes the checks.
Entry-level / new-grad full-time roles are the priority; internships are at most 1 or 2 per run and only when the posting states sponsorship (see Mix). Internship searches also prioritize AI/ML roles.

## Eligibility rules

### Sponsorship (applies to both categories)
- Read the full posting for work-authorization language.
- **Exclude** postings that say they will not sponsor "now or in the future", or "must not require sponsorship now or in the future". For a candidate who needs sponsorship in the future, these are a no.
- **Keep, flag as OK** postings that sponsor, say "visa sponsorship available", or say nothing about it AND the company is a known H-1B sponsor (check quickly via MyVisaJobs / h1bdata / DOL data when cheap).
- **Keep, flag as "Unclear"** if the posting is silent and sponsor history is unknown.
- Postings that say "must be authorized to work in the US" and nothing about future sponsorship are fine: note "authorization required, no future-sponsorship exclusion".
- Note whether the company is known to use E-Verify when it is easy to find (some student work permits require it).

### Graduation scenarios
If `<ALT_GRAD_DATE>` is set, the candidate's graduation may move from **<GRAD_DATE>** to **<ALT_GRAD_DATE>**. Until it is decided, never pick one for them and never enter a graduation date they have not chosen.
- For every internship, store a `gradFit` field on the tracker document: `both` (no graduation restriction, or accepts <GRAD_DATE> graduates), `later` (needs a graduation later than <GRAD_DATE> but includes <ALT_GRAD_DATE>), `planned` (only a <GRAD_DATE> or earlier graduate qualifies), or `unclear` (the posting does not say). The private notes may name these values differently for the tracker page; use their names.
- `later` internships stay in the list; the tracker shows them as fitting only the later graduation. Explain the dependency in `gradReq` (e.g. "Needs graduation <ALT_GRAD_DATE> or later").
- Internships that end before <GRAD_DATE> are `both` even if the posting says "currently enrolled".
- Full-time roles: if the posting requires graduating by a date between the two, it fits the <GRAD_DATE> plan only; mention in `gradReq` that it would not fit the later graduation.

### Summer <INTERN_YEAR> internships
- Must be open to students who **return to school after the internship**, OR explicitly accept **<GRAD_DATE> graduates**.
- Because the candidate graduates <GRAD_DATE>, an internship that requires returning to school for a later semester is only valid if they can plausibly qualify. Check the posting's wording carefully and record it in `gradReq` (e.g. "Must return to school in the fall", "Accepts <GRAD_DATE> grads", "Not stated").
- If the posting says it requires returning to complete a degree and the user will have graduated, flag it as "Risky: requires return to school" rather than silently dropping it. Exclude it only if the posting is explicit that graduated students are ineligible.

### Spring <INTERN_YEAR> co-ops/internships
- Same logic: record enrollment/return-to-school requirement in `gradReq`. Spring co-ops usually require current enrollment; flag accordingly.

## Sponsor-friendly company list (search these first)

`sponsor_companies.csv` in this skill's folder (`<SKILLS_DIR>/job-search/sponsor_companies.csv`) is a curated starting list of US companies that file many H-1B petitions, with priority tiers (1 = best bet) and notes. It was compiled in October 2026 from 2026 H-1B ranking articles.

- **Tier 0 (top priority, user-chosen big tech and AI labs: Google, Amazon, Microsoft, Apple, Meta, OpenAI, Anthropic):** search each one's own careers site directly on every run for matching new-grad (priority) and Summer/Spring <INTERN_YEAR> internship roles, even if they do not appear on any job-board list. Do not skip a Tier 0 company because it was missing from the SimplifyJobs lists; if a Tier 0 company has no qualifying open role, say so in the chat summary.
- **Amazon and its subsidiaries (Audible, Twitch, Ring, Annapurna Labs, Zoox is separate) are all on amazon.jobs, and many entry-level engineering roles are NOT labeled "new grad" or "early career" in the title** (e.g. a plain "Software Development Engineer" whose basic qualifications are just "Bachelor's degree" and "experience programming in one language"). Do not rely on title keywords for Amazon. Instead scan recent postings from `https://www.amazon.jobs/en/search.json?base_query=<q>&country=USA&result_limit=100&offset=<n>&sort=recent` for several queries (software development engineer, software engineer, machine learning engineer, data engineer, front end, full stack), page through at least 300 results each, then filter on `posted_date` (inside the age window) and on `basic_qualifications` (no "N years" of experience required, Bachelor's or Master's degree). Include roles in New Jersey and New York. Audible and similar career sites (e.g. audiblecareers.com) link to the same amazon.jobs posting, so search amazon.jobs.
- **Example, a careers site without an API (Uber)**: jobs.uber.com has no public API and is not on Greenhouse/Ashby/Workday, so use a Claude in Chrome tab. Search with `https://jobs.uber.com/en/jobs/?search=<query>&radius=100` (the `query=` parameter is ignored) for "software engineer", "machine learning", "data scientist", "applied scientist", "new grad"; results load client-side, so wait a few seconds and read the `/en/jobs/<id>/` links. Open each candidate page and read location, "Posted on" date, years and degree; postings usually say nothing about sponsorship (Uber is a long-time H-1B filer), so mark `Unknown`. The "Job removed" text on Uber pages is only the save-button label, not a closed job; "Apply now" leads to Uber's Oracle careers site (sign-in needed). Many Uber results are outside the US (e.g. São Paulo), check the location.
- **IBM** (careers.ibm.com, its own platform, blocked for curl): search from a Claude in Chrome tab. In the tab, `fetch('/en_US/careers/SearchJobs/<query>?jobRecordsPerPage=50&jobOffset=<n>')` returns result HTML whose `JobDetail?jobId=` links give the job IDs; then open each candidate's `JobDetail?jobId=<id>` page and read the whole page text with `document.body.innerText` (the visa sentence sits near the bottom, after "Required technical..."; the `get_page_text` tool can cut it off, so do not rely on it for sponsorship). Check `Date posted`, country and `Position type`. In practice almost every IBM US entry-level posting says "IBM will not be providing visa sponsorship ... now or in the future", which excludes the user; keep IBM at Tier 3 and include a role only if the full page text has no such sentence.
- Then go on to Tier 1, then Tier 2, then Tier 3. Check each tier's careers sites directly for matching new-grad and internship roles before (or alongside) searching job boards.
- Filing history does not guarantee that a specific posting sponsors. A company on the list can still post roles that say "no sponsorship now or in the future" (IBM early-career roles do). Always apply the posting-level sponsorship rule.
- Roles at companies not on the list are still allowed if they pass all checks (job boards often surface startups and mid-size companies that sponsor). Companies that show clear sponsorship language in a posting are good candidates to add to the list.
- **Keeping the list fresh:** if the file is more than ~6 months old, or the user asks, refresh it with a web search for current top H-1B sponsors and "companies that sponsor international students / OPT / new grads", then update the CSV (keep the same columns). When a run discovers a company with explicit sponsorship language, append it to the CSV with a short note. Do not remove companies without evidence.
- Policy context to keep in mind (verify if it matters for the answer): the 2025 $100,000 H-1B fee proclamation applies to new petitions for people outside the US, and USCIS guidance exempts students changing status inside the US. A June 2026 court ruling reportedly vacated the fee policy. Do not give legal advice; suggest confirming with the school's international office.

## No repeats across runs

Every run must return only jobs the user has not been shown before.

- **Before searching**, read every document in the `jobs` collection of <TRACKER_NAME> (<TRACKER_URL>) with the ArtifactData tool (action `list`, page with `cursor`). Build a set of "seen" keys from each row: the normalized `url` (lowercase, no query string or tracking parameters, no trailing slash), the `company` + `jobId` pair, and the `company` + `title` + `location` triple (lowercased, whitespace-trimmed; strip any " (Tier N)" suffix from company). Ignore the `applied` field.
- **Match on any one key.** A candidate that matches a seen key is skipped, even if it was found through a different job board or URL, and even if its status has since changed. Do not re-list it.
- Apply this check right after discovery and before the expensive careers-page verification, so no time is spent re-verifying seen jobs. Skipped duplicates do not count toward `max_posts`.
- If fewer new qualifying jobs exist than `max_posts`, return fewer and say so in the summary ("only N new jobs since the last run"). Never pad with previously listed jobs.
- Report how many candidates were skipped as already seen.
- If the tracker has no jobs yet, there is nothing to dedupe against; proceed normally. Do not keep any other ledger.

## Skip what the user already applied to

Before searching, also read the `email_applications` collection of the tracker page (the application history from email and from the apply skill). Ignore rows with `needsReview: true`. Then skip a candidate when:

- the user already applied to it: a row with the same company (ignore "Inc", "LLC", " (Tier N)" and subsidiaries, e.g. "Amazon Web Services" is Amazon) and a similar role, at any date;
- the user is in an active process there: any row for that company with status `assessment`, `interview` or `offer` skips the whole company;
- the same or a similar role there rejected the user in the last 90 days.

A rejection does not skip the rest of the company, since big companies reject often and hire across many teams. Apply this together with "No repeats across runs", before careers-page verification, and report how many were skipped for each reason.

## LinkedIn as a discovery source

LinkedIn is used only to **find** postings that other sources miss. It is never the source of truth.

- **Access:** the user signs in to LinkedIn in Chrome and hands over a tab (Claude in Chrome). Never sign in, enter credentials, or create anything. If the tab is not signed in, stop and ask the user.
- **Allowed actions (read-only):** open LinkedIn job search URLs, set the search filters (keywords, location, date posted "Past week", experience level Entry level / Associate, job type Full-time or Internship), scroll results, and open a posting to read the title, company, location, posted date and where "Apply" leads. That is all.
- **Forbidden on LinkedIn:** posting, commenting, reacting, messaging, connecting, following, saving jobs, setting up job alerts, creating or editing anything on the profile, clicking **Easy Apply** or any apply/submit button, accepting terms or prompts, visiting other people's profiles, and changing account settings. Dismiss any popup (premium upsell, notification permission, "apply with profile") without accepting. Do not export or scrape beyond the visible job results.
- **Searching:** run the user's role families as keyword searches ("machine learning engineer", "software engineer new grad", "software engineer II") with the preferred locations (New York, San Francisco, Seattle, remote) and "Past week". A few pages per query, with a pause of a few seconds between actions, so the account is not flagged.
- **Find the company posting:** for each LinkedIn result, locate the same job on the company's own careers site or ATS (Greenhouse, Ashby, Workday, Lever) by company + title + location or requisition id. The LinkedIn Apply link often points to the ATS; use it only to find the company page, and open that page in a **separate** tab. Verify there exactly as in step 3 (open, original posted date, years, sponsorship and graduation wording).
- **If the company page cannot be found**, or the job is closed or older than the window there, drop it and count it ("LinkedIn only, not verified"). Never list a job whose only evidence is LinkedIn.
- Record `source` = "LinkedIn, verified on company site", the company careers URL as `url`, and the LinkedIn URL in `boardUrl`.
- Dedupe against the tracker like every other source; LinkedIn reposts are common.
- Never store LinkedIn credentials or session data anywhere.

## Process

For every candidate listing, follow these steps. Do not skip step 3.

1. **Discover.** Start with the public SimplifyJobs lists (`https://raw.githubusercontent.com/SimplifyJobs/New-Grad-Positions/dev/README.md` and `.../Summer<INTERN_YEAR>-Internships/dev/README.md`): parse the HTML tables and skip rows flagged with 🛂 (no sponsorship), 🇺🇸 (citizenship) or 🔒 (closed). Then search broadly. Use WebSearch/WebFetch, and the built-in browser for JS-rendered pages (careers pages often return empty to plain fetch; wait a few seconds and read page text). Sources: LinkedIn, Indeed, Handshake, Glassdoor, Wellfound, Simplify, Built In, GitHub new-grad/internship lists (e.g. SimplifyJobs, speedyapply), company career sites, and "new grad 2027" / "software engineer new grad" queries. Use several query variations per role family.
2. **Shortlist.** Drop anything non-US, senior-level, or with a no-sponsorship-now-or-future statement.
3. **Verify on the company's own careers page (required).** Quickest reliable method: the public posting data behind the company's ATS (Greenhouse `boards-api.greenhouse.io/v1/boards/<board>/jobs/<id>`, Ashby `api.ashbyhq.com/posting-api/job-board/<board>`, Workday `<host>/wday/cxs/<tenant>/<site>/job/<path>`), which returns 404 or `canApply: false` for closed jobs and gives the full description to scan for sponsorship and graduation wording. Use the browser for pages without such an API (e.g. Google). Job boards often show stale or closed postings. For each shortlisted job:
   - Find the company's official careers site (not a job board) and locate the same posting by title, location, or requisition/job ID.
   - Confirm it is **currently open** (Apply button present, not "no longer accepting applications", not redirecting to a generic search page).
   - Record the careers-page URL as the primary link. If it cannot be found on the company site, mark `Verified_On_Company_Site` = "No" and `Status` = "Unverified / possibly closed" and list it in a separate lower section or leave it out if it appears clearly dead.
   - Re-read the sponsorship and graduation language on the company's posting (it is the source of truth over the board). Read the FULL page text for the sponsorship sentence: it is often in a footer section below the requirements, and some page-text tools stop before it.
4. **Expand.** While on each company's careers page, look for other open roles that match the target families and eligibility rules (other new-grad or internship openings, other teams, other US locations). Add those as additional rows with `Source` = "Found via company careers page".
5. **De-duplicate** within this run by company + title + location + job ID, and drop anything already in an earlier tab of the workbook (see "No repeats across runs").
6. **Apply the cap.** Keep the best `max_posts` rows: verified-open first, then the priority order in "Targets" (AI/ML before general software), then Tier 0 companies, then roles whose posting explicitly offers sponsorship, then Tier 1 companies, then freshest posting date (within the age window). Respect the full-time/internship mix above.
7. **Write the output** (see below) and give the user a short summary in chat.

## Output

Results go to **the tracker page** (formerly Job Posts Tracker): <TRACKER_URL>

- Each run adds one document per job to the artifact's `jobs` collection with the ArtifactData tool (action `batch`, up to 50 writes per call; write each job as a JSON file and pass `file_path`). Never overwrite or delete existing documents, and never change their `applied` / `appliedAt` fields.
- Document id: `r<MMDD>-<NN>-<company-slug>` (e.g. `r1011-03-stripe`), where MMDD is the run date and NN the row number. For a same-day rerun use `r<MMDD>b-...`.
- Fields (exact names): `run` (`MM_DD`, e.g. `10_11`; same-day reruns `10_11_2`), `order` (row number, full-time first then internships, by company), `title`, `type`, `company` (add " (Tier N)" if on sponsor_companies.csv), `location`, `posted` (original posting date, YYYY-MM-DD, required), `url` (careers-page link), `boardUrl`, `sponsorship`, `status`, `gradReq`, `verified`, `source`, `notes`, `jobId`, `applied` (false), `appliedAt` (null).
- `type` is one of `Full-Time Entry Level`, `Internship Summer <INTERN_YEAR>`, `Internship Spring <INTERN_YEAR>`, `Co-op`.
- `sponsorship` is `Offers sponsorship`, `Unknown` (posting does not say), or `Auth required, no future-sponsorship exclusion`. Never include postings that exclude future sponsorship.
- `gradReq` is required for internships (prefix with `RISKY:` when the posting requires returning to school or a later graduation date than <GRAD_DATE>); "N/A" for full-time unless stated.
- No CSV backups: the artifacts are the only record. Do not write job_posts_*.csv files.
- If the ArtifactData tool or the artifact is unavailable, say so and stop; do not write a CSV instead.
- Sort: all full-time entry-level rows first, then internships/co-ops. Within each group, sort by company name.

## Final chat summary

After saving, report: the tracker link, the `max_posts` value used, counts (full-time vs internship, verified vs unverified), the top 5 best-fit roles, any notable risks, and how many were dropped for no-sponsorship language, being closed, or being older than `max_age_days` or having no findable date. Keep it brief.

## Browser safety: this skill is for THIS computer only

- Which browser: `<APPLY_BROWSER>` in the config. With `built-in`, use the Claude app's built-in browser wherever this skill says "Claude in Chrome tab"; the device rules below are for `chrome` only. With `none`, skip the sources that need a browser and use only web search, web fetch and the ATS APIs.

- This skill, and the `apply` and `cover-letter` skills, belong to one computer. If several people's browsers are connected to the same Claude account, never act on another person's browser.
- Several Chrome browsers can be connected to the same Claude account. Before any browser action, call `list_connected_browsers`, identify the **local** one (`isLocal`, and the one the user confirmed in the Connect pop-up), and pin it with `select_browser` by device id. Never use the session's default or "in use" browser without confirming it is the one the user picked.
- **Name and register the browsers.** Keep `<PRIVATE_DIR>/browsers.json`: the user's local browser is saved by name and device id (`local`), and any other connected browser is saved under `other` with its owner. When the user connects through `switch_browser` they can type a name for that browser in the pop-up (use something like "My-Mac-LOCAL"); record the name and the device id from `list_connected_browsers`. Always select by that name/id, never by "in use" or by default.
- **Identify by name:** the local browser is `<BROWSER_NAME>` (see `browsers.json`). Pin it by name and device id with `select_browser`; if the connected browser's name or device id does not match, stop, take no other action, report it, and ask.
- Re-check before every new batch of browser work, and **immediately after any "connection lost" error or when the tab group is recreated**: list browsers again, confirm the pinned device is still the one in use, and look at the first tab's page to confirm it is the expected one (for example the user's tabs are present). If anything differs, **stop, take no further browser actions, tell the user, and ask**.
- **Tab group gone:** when the user asks to apply to a specific job and the tab group no longer exists, do not stop to ask: call `list_connected_browsers`, confirm the local browser by name and device id (`<BROWSER_NAME>`, see `browsers.json`), then create a new group with `createIfEmpty` and open a new tab for that job. If the name or device id does not match, or the other laptop's browser is the only one connected, stop and ask.
- Never use `switch_browser` on your own after a drop; ask the user first, then show the Connect pop-up so they choose.
- If a session ever lands on a browser that is not the user's, stop, close only the tabs this session opened, and report exactly what was touched.

## Guardrails

- Only read job postings; do not apply, create accounts, sign in, or submit forms on the user's behalf.
- If a job site requires login (Handshake, LinkedIn), do not log in. Ask the user to sign in and hand over the tab, and use it read-only: see the LinkedIn section for exactly what is and is not allowed.
- Do not invent details. If something is not stated in the posting, write "Not stated".
- Be honest about uncertainty: if a posting could not be verified on the company site, say so in the spreadsheet and the summary.
