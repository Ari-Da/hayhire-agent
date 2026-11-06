#!/bin/sh
# Lists personal skills in ~/.claude/skills that could answer the same requests
# as HayHire ("apply to ...", "run a job search", "update history"): skills
# about jobs or applications that are not part of this plugin. It only lists
# them; the setup skill asks before moving any.
#
# Output, one per line:  <kind> <path>
#   old-hayhire  a link to an earlier HayHire install (safe to remove)
#   broken       a link to a folder that no longer exists
#   other        another job skill, for example from an older kit
SKILLS="$HOME/.claude/skills"
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
[ -d "$SKILLS" ] || exit 0
for dir in "$SKILLS"/*; do
  [ -e "$dir" ] || [ -L "$dir" ] || continue
  name="$(basename "$dir")"
  target="$(cd "$dir" 2>/dev/null && pwd -P)"
  # HayHire itself, loaded from this folder
  [ "$target" = "$ROOT" ] && continue
  if [ -L "$dir" ] && [ ! -e "$dir" ]; then
    echo "broken $dir"
    continue
  fi
  file="$dir/SKILL.md"
  [ -f "$file" ] || continue
  if grep -q "job-agent-private" "$file"; then
    echo "old-hayhire $dir"
  elif grep -qiE "^description:.*(job search|jobs|job application|apply to|application history|resume|cover letter|recruiter|internship)" "$file" \
       && ! grep -q "^description: HayHire:" "$file"; then
    echo "other $dir"
  else
    case "$name" in *job*|apply|*apply*|cover-letter|*pipeline*) echo "other $dir" ;; esac
  fi
done
