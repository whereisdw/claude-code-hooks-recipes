#!/bin/sh
# SessionStart / SessionEnd hook: keep the Mac from idle-sleeping while a Claude Code session is open.
# Register the same script for both events; it reads hook_event_name to decide.
#
# Limits: caffeinate -i only blocks idle sleep. Closing the lid without an external display still
# sleeps the Mac (that needs `sudo pmset -a disablesleep 1` and undoing it afterwards).
event=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("hook_event_name",""))' 2>/dev/null)
dir="$HOME/.claude/hooks/state"; mkdir -p "$dir"
pidfile="$dir/caffeinate-$PPID.pid"   # $PPID = the claude process that runs this hook
case "$event" in
  SessionStart)
    if [ ! -f "$pidfile" ] || ! kill -0 "$(cat "$pidfile" 2>/dev/null)" 2>/dev/null; then
      nohup caffeinate -i -w "$PPID" >/dev/null 2>&1 &
      echo $! > "$pidfile"
    fi ;;
  SessionEnd)
    [ -f "$pidfile" ] && { kill "$(cat "$pidfile")" 2>/dev/null; rm -f "$pidfile"; } ;;
esac
exit 0
