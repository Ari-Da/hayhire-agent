#!/bin/sh
# Removes the job agent from Claude Code: the skill links and the link to the
# private folder that install.sh made. It can back up your data first, and
# move the whole job-agent folder to the Trash.
#
# Usage: ./uninstall.sh                 asks about backup and the folder
#        ./uninstall.sh --backup        back up first (default when not asked)
#        ./uninstall.sh --no-backup     skip the backup
#        ./uninstall.sh --delete-folder also move the job-agent folder to the Trash
#        ./uninstall.sh --keep-folder   keep the folder (default)
#
# Your tracker page on claude.ai is not touched. Saying "uninstall job agent"
# to Claude does all of this, and can export and delete the tracker page too.
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
BASE="$(dirname "$ROOT")"
PRIVATE="$BASE/private"
SKILLS="job-agent-setup job-search apply cover-letter sync-applications job-pipeline"

backup=""
delete_folder=""
for arg in "$@"; do
  case "$arg" in
    --backup) backup=yes ;;
    --no-backup) backup=no ;;
    --delete-folder) delete_folder=yes ;;
    --keep-folder) delete_folder=no ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg (see --help)"; exit 2 ;;
  esac
done

# ask "question" default -> prints yes/no; asks only in a terminal
ask() {
  if [ -t 0 ]; then
    printf "%s " "$1" >&2
    read -r answer
    case "$answer" in [Yy]*) echo yes ;; [Nn]*) echo no ;; *) echo "$2" ;; esac
  else
    echo "$2"
  fi
}

[ -n "$backup" ] || backup=$(ask "Back up your data first? [Y/n]" yes)
[ -n "$delete_folder" ] || delete_folder=$(ask "Also move the folder $BASE to the Trash? [y/N]" no)

if [ "$backup" = yes ] && [ -d "$PRIVATE" ]; then
  "$ROOT/backup.sh"
fi

for skill in $SKILLS; do
  link="$HOME/.claude/skills/$skill"
  if [ -L "$link" ]; then
    case "$(readlink "$link")" in
      "$ROOT"/*) rm "$link"; echo "Removed skill $skill" ;;
      *) echo "Left skill $skill: it points to $(readlink "$link"), not to this copy" ;;
    esac
  elif [ -e "$link" ]; then
    echo "Left skill $skill: it is not a link made by install.sh"
  fi
done

link="$HOME/.claude/job-agent-private"
if [ -L "$link" ] && [ "$(readlink "$link")" = "$PRIVATE" ]; then
  rm "$link"
  echo "Removed the private folder link"
fi

if [ "$delete_folder" = yes ]; then
  if [ "$BASE" = "$HOME" ] || [ "$BASE" = "/" ] || [ ! -d "$BASE/public" ]; then
    echo "Not moving $BASE: it is not a job-agent folder with public/ inside. Delete it yourself if you meant to."
  elif [ -d "$HOME/.Trash" ]; then
    dest="$HOME/.Trash/$(basename "$BASE")-$(date +%Y-%m-%d-%H%M%S)"
    mv "$BASE" "$dest"
    echo "Moved $BASE to the Trash"
  else
    echo "No Trash folder found: delete $BASE yourself."
  fi
fi

cat <<'EOF'

Done. Left for you (the script cannot do these):
- Tracker page: delete it in your claude.ai artifacts if you no longer need it.
- Gmail: remove the app's access at https://myaccount.google.com/permissions
- Claude Code memory for this project: ~/.claude/projects/<folder name>/
To set up again: clone the repo, run ./public/install.sh, then say
"restore my job data" in Claude.
EOF
