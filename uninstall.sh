#!/bin/sh
# Removes HayHire from Claude Code: the plugin, the link to your private
# folder, and links left by older installs. It can back up your data first,
# and move your job-agent folder to the Trash.
#
# Usage: sh uninstall.sh                 asks about backup and the folder
#        sh uninstall.sh --backup        back up first (default when not asked)
#        sh uninstall.sh --no-backup     skip the backup
#        sh uninstall.sh --delete-folder also move your job-agent folder to the Trash
#        sh uninstall.sh --keep-folder   keep the folder (default)
#
# Your tracker page on claude.ai is not touched. Saying "uninstall hayhire"
# to Claude does all of this, and can export and delete the tracker page too.
set -e
ROOT="$(cd "$(dirname "$0")" && pwd -P)"
LINK="$HOME/.claude/job-agent-private"
SKILLS="$HOME/.claude/skills"
# Skill names used by HayHire before it became a plugin
OLD_SKILLS="job-agent-setup job-search apply cover-letter sync-applications job-pipeline"

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

PRIVATE=""
[ -d "$LINK" ] && PRIVATE="$(cd "$LINK" && pwd -P)"
BASE=""
[ -n "$PRIVATE" ] && BASE="$(dirname "$PRIVATE")"

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
if [ -z "$delete_folder" ] && [ -n "$BASE" ]; then
  delete_folder=$(ask "Also move your data folder $BASE to the Trash? [y/N]" no)
fi

if [ "$backup" = yes ] && [ -n "$PRIVATE" ]; then
  sh "$ROOT/backup.sh"
fi

# is_hayhire link -> true for a broken link or a link into a HayHire copy
is_hayhire() {
  [ ! -e "$1" ] && return 0
  grep -q "job-agent-private" "$1/SKILL.md" 2>/dev/null && return 0
  grep -q '"name": "hayhire"' "$1/.claude-plugin/plugin.json" 2>/dev/null
}

# Links from older installs (one link per skill), and the skills-folder link
# made by install.sh. Only links into a HayHire copy are removed.
for skill in $OLD_SKILLS hayhire; do
  link="$SKILLS/$skill"
  [ -L "$link" ] || continue
  target="$(readlink "$link")"
  if is_hayhire "$link"; then
    rm "$link"
    echo "Removed the link $link"
  else
    echo "Left $link: it points to $target, which is not HayHire"
  fi
done

if [ -L "$LINK" ]; then
  rm "$LINK"
  echo "Removed the private folder link"
fi

if [ "$delete_folder" = yes ] && [ -n "$BASE" ]; then
  # Move the whole folder only if it holds nothing but HayHire's own parts;
  # otherwise move just the private folder.
  others="$(ls -A "$BASE" | grep -vxE 'private|public|email_fetcher|\.DS_Store' || true)"
  if [ "$BASE" = "$HOME" ] || [ "$BASE" = "/" ] || [ -n "$others" ]; then
    what="$PRIVATE"
  else
    what="$BASE"
  fi
  if [ -n "$what" ] && [ -d "$HOME/.Trash" ]; then
    mv "$what" "$HOME/.Trash/$(basename "$what")-$(date +%Y-%m-%d-%H%M%S)"
    echo "Moved $what to the Trash"
    [ "$what" = "$PRIVATE" ] && [ -n "$others" ] && echo "Left $BASE: it holds other files too."
  elif [ -n "$what" ]; then
    echo "No Trash folder found: delete $what yourself."
  fi
fi

# The plugin itself, if it was installed from the marketplace. Last, since
# this script may be running from the plugin's own folder.
if command -v claude > /dev/null 2>&1 && claude plugin list 2>/dev/null | grep -q "hayhire@hayhire"; then
  claude plugin uninstall hayhire@hayhire && echo "Uninstalled the HayHire plugin"
  claude plugin marketplace remove hayhire > /dev/null 2>&1 || true
  plugin_left=""
else
  plugin_left="- The plugin, if it was installed from the marketplace: run
  claude plugin uninstall hayhire@hayhire   (or /plugin in Claude Code)"
fi

cat <<EOF

Done. Left for you (the script cannot do these):
$plugin_left
- Tracker page: delete it in your claude.ai artifacts if you no longer need it.
- Gmail: remove the app's access at https://myaccount.google.com/permissions
- Claude Code memory for this project: ~/.claude/projects/<folder name>/
To set up again: install the plugin, then say "restore my job data" in Claude.
EOF
