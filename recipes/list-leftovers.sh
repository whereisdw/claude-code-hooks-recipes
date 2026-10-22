#!/bin/sh
# SessionEnd hook: list processes that were started inside this Claude Code session and are still running
# (dev servers, watchers, test runners). They share the session's process group.
# Set LEFTOVERS_KILL=1 to send them SIGTERM instead of just listing.
pgid=$(ps -o pgid= -p "$PPID" 2>/dev/null | tr -d ' ')
[ -n "$pgid" ] || exit 0
left=$(pgrep -g "$pgid" 2>/dev/null | grep -v -x -e "$$" -e "$PPID")
[ -n "$left" ] || exit 0
log="$HOME/.claude/hooks/leftovers.log"; mkdir -p "$(dirname "$log")"
{
  echo "== $(date '+%F %T') session $PPID left:"
  for p in $left; do ps -o pid=,etime=,command= -p "$p" 2>/dev/null | cut -c1-160; done
} >> "$log"
if [ "${LEFTOVERS_KILL:-0}" = "1" ]; then
  for p in $left; do kill "$p" 2>/dev/null; done
  echo "killed: $left" >> "$log"
fi
osascript -e "display notification \"$(echo "$left" | wc -l | tr -d ' ') process(es) still running — see ~/.claude/hooks/leftovers.log\" with title \"Claude Code\"" >/dev/null 2>&1
exit 0
