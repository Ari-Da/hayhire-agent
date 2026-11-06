#!/bin/sh
# Creates the private folder from the examples and links it at
# ~/.claude/job-agent-private, where every skill looks for it. The setup skill
# runs this; nothing in it is ever part of the plugin or the repo.
#
# Usage: sh init_private.sh [folder]
#   folder  where to keep your data (default: ~/job-agent/private). Ignored
#           when the link already exists: the existing folder is kept.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LINK="$HOME/.claude/job-agent-private"

if [ -L "$LINK" ] && [ -d "$LINK" ]; then
  PRIVATE="$(cd "$LINK" && pwd -P)"
  new=""
else
  PRIVATE="${1:-$HOME/job-agent/private}"
  case "$PRIVATE" in "~"/*) PRIVATE="$HOME/${PRIVATE#\~/}" ;; esac
  new=yes
fi
BASE="$(dirname "$PRIVATE")"

mkdir -p "$PRIVATE/apply" "$PRIVATE/cover-letter" "$PRIVATE/notes" "$PRIVATE/jobs/resume"
chmod 700 "$PRIVATE"
if [ ! -f "$PRIVATE/config.json" ]; then
  # The example uses ~/job-agent; point it at the folder actually used.
  sed "s|~/job-agent/|$BASE/|g" "$ROOT/examples/config.example.json" > "$PRIVATE/config.json"
fi
[ -f "$PRIVATE/apply/profile.md" ] || cp "$ROOT/examples/profile.example.md" "$PRIVATE/apply/profile.md"
[ -f "$PRIVATE/browsers.json" ] || cp "$ROOT/examples/browsers.example.json" "$PRIVATE/browsers.json"
[ -f "$PRIVATE/cover-letter/facts.json" ] || cp "$ROOT/examples/facts.example.json" "$PRIVATE/cover-letter/facts.json"
[ -f "$PRIVATE/blocklist.txt" ] || : > "$PRIVATE/blocklist.txt"
find "$PRIVATE" -type f -exec chmod 600 {} +

mkdir -p "$HOME/.claude"
ln -sfn "$PRIVATE" "$LINK"

if [ -n "$new" ]; then
  echo "Created your private folder at $PRIVATE"
else
  echo "Using your existing private folder at $PRIVATE"
fi
BACKUPS="${HAYHIRE_BACKUP_DIR:-$HOME/hayhire-backups}"
if ls "$BACKUPS"/hayhire-backup-*.tar.gz > /dev/null 2>&1; then
  echo "Found a backup in $BACKUPS: say \"restore my job data\" to bring it back."
fi
