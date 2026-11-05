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
# Usage: ./backup.sh            (archive goes to ~/hayhire-backups)
#        HAYHIRE_BACKUP_DIR=/some/dir ./backup.sh
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
BASE="$(dirname "$ROOT")"
BACKUP_DIR="${HAYHIRE_BACKUP_DIR:-$HOME/hayhire-backups}"

if [ ! -d "$BASE/private" ]; then
  echo "No private folder at $BASE/private: nothing to back up."
  exit 1
fi

items="private"
for f in email_fetcher/data email_fetcher/settings.json email_fetcher/credentials.json; do
  [ -e "$BASE/$f" ] && items="$items $f"
done

umask 077
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
out="$BACKUP_DIR/hayhire-backup-$(date +%Y-%m-%d-%H%M%S).tar.gz"

# shellcheck disable=SC2086
tar -czf "$out" -C "$BASE" --exclude '__pycache__' --exclude '.DS_Store' $items
tar -tzf "$out" > /dev/null
chmod 600 "$out"

if [ -d "$BASE/private/backup/tracker" ]; then
  tracker="includes the tracker export"
else
  tracker="no tracker export: ask Claude to \"back up my job data\" to include the tracker rows"
fi
echo "Backed up to $out ($tracker)."
echo "It holds personal data: keep it on this computer, never in a repo."
