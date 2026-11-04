# The harness

The harness is the `job-pipeline` skill plus the email fetcher's sync. It turns four separate tools into one flow:

1. **Find:** `job-search` adds verified jobs to the tracker, skipping anything seen before, anything already applied to, companies with an interview under way, and roles that rejected the person in the last 90 days.
2. **Apply:** `apply` fills the form in the person's own Chrome, attaches the right resume, writes a cover letter only when the form asks for one, drafts essays for review, and saves a PDF record. It stops before Submit.
3. **Record:** on "submitted", `apply` marks the job applied and adds a history row straight away, so the stats update immediately.
4. **Reconcile:** "update history" runs the email tracker and merges what Gmail shows into the history: confirmation links, rejections, assessments and interviews. Applications made outside the tool are added too.

## What runs, and when

See the diagram in the [main README](../README.md#how-it-fits-together). Each step runs only when the person asks; nothing is scheduled.

## Where things live

```text
job-agent/
  public/          this repo: the only copy of the skills
  email_fetcher/   Gmail reader, its own repo
  private/         never committed
    config.json      values for every <PLACEHOLDER> in the skills
    notes/<skill>.md personal rules each skill reads after its own
    apply/profile.md, cover-letter/facts.json, browsers.json, jobs/
```

Every skill starts by reading `~/.claude/job-agent-private/config.json` and its notes file, so the skill text stays generic and can be published as is.

## Why the harness is an agent, not a script

Finding and applying need a browser and judgement, and the tracker database can only be written through Claude's tools. Python reads Gmail; the agent does everything that touches the browser or the page.

## Rules it enforces

- One writer per collection, and nothing deletes history rows.
- The tracker page must stay private.
- The person submits every application.
- Scheduling is off by default; steps run when asked.
