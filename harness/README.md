# The harness

The harness is the `hayhire:pipeline` skill plus the email fetcher's sync. It turns four separate tools into one flow:

1. **Find:** `hayhire:search` adds verified jobs to the tracker, skipping anything seen before, anything already applied to, companies with an interview under way, and roles that rejected the person in the last 90 days.
2. **Apply:** `hayhire:apply` fills the form in the browser the person chose at setup (their own Chrome with Claude in Chrome, or the Claude app's built-in browser), attaches the right resume (with the built-in browser, the person uploads it), writes a cover letter only when the form asks for one, drafts essays for review, and saves a PDF record. It stops before Submit.
3. **Record:** on "submitted", `hayhire:apply` marks the job applied and adds a history row straight away, so the stats update immediately. If the person forgets, `hayhire:apply` keeps a short waiting list and checks it on the next command (is the tab showing a confirmation page?) and after each email sync (did a confirmation email arrive?).
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
- Who can read the tracker's data is the owner's choice (`TRACKER_SHARING`, private by default). See [Sharing the tracker](../README.md#sharing-the-tracker).
- The person submits every application.
- Scheduling is off by default; steps run when asked.
