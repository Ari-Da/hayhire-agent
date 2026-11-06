#!/bin/sh
# Backs up everything personal the job agent keeps on this computer into one
# archive, outside the job-agent folder, so it survives an uninstall:
#
#   private/                     answers, notes, resumes, cover letters,
#                                records, and the tracker export (if made)
#   email_fetcher/data/          email tracking state and its local copy
#   email_fetcher/settings.json  which accounts to read
#   email_fetcher/credentials.json  the Google OAuth client, if present
#
# Gmail login tokens are left out: they expire, and you sign in again after a
# restore. The tracker page itself lives on claude.ai; ask Claude to "back up
# my job data" to export its rows into private/backup/tracker/ first.
#
# Usage: sh backup.sh            (archive goes to ~/hayhire-backups)
#        HAYHIRE_BACKUP_DIR=/some/dir sh backup.sh
set -e
LINK="$HOME/.claude/job-agent-private"
BACKUP_DIR="${HAYHIRE_BACKUP_DIR:-$HOME/hayhire-backups}"

if [ ! -d "$LINK" ]; then
  echo "No private folder linked at $LINK: nothing to back up."
  exit 1
fi
PRIVATE="$(cd "$LINK" && pwd -P)"
BASE="$(dirname "$PRIVATE")"

# The email fetcher's folder, from config.json (default: next to private/)
EMAIL="$(sed -n 's/.*"EMAIL_FETCHER_DIR"[^"]*"\([^"]*\)".*/\1/p' "$PRIVATE/config.json" 2>/dev/null)"
case "$EMAIL" in "~"/*) EMAIL="$HOME/${EMAIL#\~/}" ;; "") EMAIL="$BASE/email_fetcher" ;; esac

items="$(basename "$PRIVATE")"
if [ "$(dirname "$EMAIL")" = "$BASE" ]; then
  name="$(basename "$EMAIL")"
  for f in data settings.json credentials.json; do
    [ -e "$EMAIL/$f" ] && items="$items $name/$f"
  done
fi

umask 077
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
out="$BACKUP_DIR/hayhire-backup-$(date +%Y-%m-%d-%H%M%S).tar.gz"

# shellcheck disable=SC2086
tar -czf "$out" -C "$BASE" --exclude '__pycache__' --exclude '.DS_Store' --exclude 'token*.json' $items
tar -tzf "$out" > /dev/null
chmod 600 "$out"

if [ -d "$PRIVATE/backup/tracker" ]; then
  tracker="includes the tracker export"
else
  tracker="no tracker export: ask Claude to \"back up my job data\" to include the tracker rows"
fi
echo "Backed up to $out ($tracker)."
echo "It holds personal data: keep it on this computer, never in a repo."
