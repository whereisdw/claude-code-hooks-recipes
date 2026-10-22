#!/bin/sh
# Notification hook: push Claude Code notifications (permission prompts, questions, idle) to your phone via ntfy.
# 1. Install the ntfy app and subscribe to a topic you made up (keep it unguessable).
# 2. export NTFY_TOPIC=your-topic   (or edit the default below)
# The message text comes from the hook input; nothing else about the session is sent.
topic="${NTFY_TOPIC:-}"
[ -n "$topic" ] || exit 0
msg=$(python3 -c '
import json,sys,os
d=json.load(sys.stdin)
kind=d.get("notification_type") or ""
m=d.get("message") or d.get("title") or "Claude Code needs you"
cwd=os.path.basename(d.get("cwd") or "")
print((cwd+": " if cwd else "")+m+((" ["+kind+"]") if kind else ""))' 2>/dev/null)
[ -n "$msg" ] || exit 0
curl -fsS -m 8 -H "Title: Claude Code" -H "Priority: high" -d "$msg" "https://ntfy.sh/$topic" >/dev/null 2>&1
exit 0
