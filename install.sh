#!/bin/sh
# For a cloned copy: loads this folder as the HayHire plugin and creates your
# private folder. Most people install from the marketplace instead (see the
# README); this is for running your own edited copy.
#
# It links ~/.claude/skills/hayhire to this folder. Claude Code loads a folder
# there that has .claude-plugin/plugin.json as a plugin, so the skills appear
# as /hayhire:setup, /hayhire:search and so on, and your edits apply at once.
# It also removes links left by older installs (one link per skill).
#
# Usage: sh install.sh [private folder]   (default: the private folder next to
#                                           this repo, e.g. ~/job-agent/private)
set -e
ROOT="$(cd "$(dirname "$0")" && pwd -P)"
SKILLS="$HOME/.claude/skills"
mkdir -p "$SKILLS"

# Older installs linked each skill on its own, under names that now clash
for skill in job-agent-setup job-search apply cover-letter sync-applications job-pipeline; do
  link="$SKILLS/$skill"
  if [ -L "$link" ] && { [ ! -e "$link" ] || grep -q job-agent-private "$link/SKILL.md" 2>/dev/null; }; then
    rm "$link"
    echo "Removed the old link $skill (HayHire now loads as one plugin)"
  fi
done

link="$SKILLS/hayhire"
if [ -L "$link" ] || [ ! -e "$link" ]; then
  ln -sfn "$ROOT" "$link"
  echo "Linked HayHire: its skills load as /hayhire:<name> in new sessions"
else
  echo "Skipped: $link already exists and is not a link. Move it, then run this again."
fi

sh "$ROOT/scripts/init_private.sh" "${1:-$(dirname "$ROOT")/private}"
echo "Done. Open Claude Code and say \"set up job agent\"."
echo "Installed HayHire from the marketplace too? Remove one: both would load."
