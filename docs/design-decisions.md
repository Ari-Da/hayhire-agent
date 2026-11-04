# Design decisions

## Human in the loop
Applying is the step with real consequences, so the agent fills forms and stops. Submitting, accepting terms, signing in and creating accounts stay with the person. Essays are drafted only from the resume and website and flagged for review.

## Verification over volume
Job boards show stale postings. Each candidate is checked on the company's own careers site or ATS API: closed postings return 404 or `canApply: false`, and the full description is scanned for sponsorship and graduation wording. Runs are capped per company and never padded with unverified jobs.

## Sponsorship and graduation rules
Postings that refuse sponsorship now or in the future are excluded. Internships are tagged by which graduation dates they fit, so a change of plan does not mean re-reviewing everything.

## Apply writes instantly, email reconciles
When the person says "submitted", the apply skill adds the application to the history at once. The email sync later finds the confirmation and fills in the link and status. Matching uses company (subsidiaries included), a similar role and a 5-day window; several or weak candidates go to review. Email only moves a status forward, and the sync never deletes. An email row a later scan cannot find is flagged, not removed.

## A local copy instead of downloads
The sync compares results against a local copy of the page's rows, updated only through its own writes. Every write carries the row's version, so a row edited by hand is refused instead of overwritten.

## Recruiter emails: rules, then a local model
Keyword search finds candidates, rules drop the obvious misses (automated senders, hiring systems, universities, interview threads, mass mail), and a small local model sorts the rest into categories. Asking for a category worked far better than a yes-or-no question with a 3B model. Email text never leaves the computer.

## Read-only by construction
Gmail tokens are checked for the read-only scope before use, and tests fail if any code calls send, delete or modify. Only the draft step holds compose access.
