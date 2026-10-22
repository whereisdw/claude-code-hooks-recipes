#!/bin/sh
# PermissionRequest hook: answer Claude Code's AskUserQuestion from the hook.
#
# By default it picks the FIRST option of every question. Replace choose() with your own logic
# (read a file, ask a server, wait for a phone tap...). Returning nothing (exit 0 with no output)
# leaves the normal terminal prompt in place.
#
# Verified on Claude Code 2.1.283: the session shows
#   ⏺ User answered Claude's questions: · <question> → <label>
# and continues without showing the prompt. Returning {"behavior":"allow"} WITHOUT updatedInput
# does not answer the question; the session keeps waiting.
python3 - <<'PY'
import json, sys

d = json.load(sys.stdin)
if d.get("tool_name") != "AskUserQuestion":
    sys.exit(0)  # not a question: no decision, normal prompt

ti = d.get("tool_input") or {}

def choose(q):
    """Return the chosen label(s) for one question dict: {question, header, options[{label, description}], multiSelect}."""
    labels = [o.get("label", "") for o in q.get("options", []) if o.get("label")]
    return labels[:1]  # default: first option

answers = {}
for q in ti.get("questions", []):
    picked = [l for l in choose(q) if l]
    if not picked:
        sys.exit(0)  # couldn't decide: leave it to the terminal
    answers[q["question"]] = ", ".join(picked) if q.get("multiSelect") else picked[0]

ti["answers"] = answers
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PermissionRequest",
                  "decision": {"behavior": "allow", "updatedInput": ti}}}))
PY
