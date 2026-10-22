#!/bin/sh
# Stop hook: macOS notification when Claude finishes a turn.
# Uses the folder name as the title so you know which session it was.
cwd=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)
name=$(basename "${cwd:-$PWD}" | sed "s/[\"\\\\]//g")
osascript -e "display notification \"Claude finished in $name\" with title \"Claude Code\" sound name \"Glass\"" >/dev/null 2>&1
exit 0
