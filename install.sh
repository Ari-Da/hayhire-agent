#!/bin/sh
# Links the skills into Claude Code and creates the private folder next to
# this repo from the examples. Nothing in private/ is ever committed: it lives
# outside the repo.
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
PRIVATE="$(dirname "$ROOT")/private"
mkdir -p "$HOME/.claude/skills"
for skill in job-agent-setup job-search apply cover-letter sync-applications job-pipeline; do
  if [ -e "$HOME/.claude/skills/$skill" ]; then
    echo "Skipped $skill: $HOME/.claude/skills/$skill already exists"
  else
    ln -s "$ROOT/skills/$skill" "$HOME/.claude/skills/$skill"
    echo "Linked $skill"
  fi
done
mkdir -p "$PRIVATE/apply" "$PRIVATE/cover-letter" "$PRIVATE/notes" "$PRIVATE/jobs"
chmod 700 "$PRIVATE"
[ -f "$PRIVATE/config.json" ] || cp "$ROOT/examples/config.example.json" "$PRIVATE/config.json"
[ -f "$PRIVATE/apply/profile.md" ] || cp "$ROOT/examples/profile.example.md" "$PRIVATE/apply/profile.md"
[ -f "$PRIVATE/browsers.json" ] || cp "$ROOT/examples/browsers.example.json" "$PRIVATE/browsers.json"
[ -f "$PRIVATE/cover-letter/facts.json" ] || cp "$ROOT/examples/facts.example.json" "$PRIVATE/cover-letter/facts.json"
# The skills find the private folder through this link
ln -sfn "$PRIVATE" "$HOME/.claude/job-agent-private"
[ -f "$PRIVATE/blocklist.txt" ] || : > "$PRIVATE/blocklist.txt"
echo "Done. Fill in the files in $PRIVATE (config.json first), and add your private terms to blocklist.txt."
