#!/bin/sh
# PermissionRequest hook: answer Claude Code's AskUserQuestion from the hook.
#
# By default it picks the FIRST option of every question. Replace choose() with your own logic
# (read a file, ask a server, wait for a phone tap...). Printing nothing (exit 0) leaves the
# normal terminal prompt in place.
#
# Verified on Claude Code 2.1.283: the session shows
#   ⏺ User answered Claude's questions: · <question> → <label>
# and continues without showing the prompt. Returning {"behavior":"allow"} WITHOUT updatedInput
# does not answer the question; the session keeps waiting.
#
# WARNING: from Claude Code 2.1.300 on, updatedInput from PreToolUse and PermissionRequest hooks is
# "validated like Claude's own input" (CHANGELOG 2.1.300), so this approach may no longer work.
# It has only been verified on 2.1.283. On newer versions, try the documented PreToolUse route:
# permissionDecision "allow" plus updatedInput.answers (CHANGELOG 2.1.85+). The same validation
# applies there, so check that the answers you return are valid input for AskUserQuestion.
HOOK_INPUT=$(cat) python3 -c "
import json, os, sys

d = json.loads(os.environ.get(\"HOOK_INPUT\") or \"{}\")
if d.get(\"tool_name\") != \"AskUserQuestion\":
    sys.exit(0)  # not a question: no decision, normal prompt

ti = d.get(\"tool_input\") or {}

def choose(q):
    # q = {question, header, options: [{label, description}], multiSelect}. Return a list of labels.
    labels = [o.get(\"label\", \"\") for o in q.get(\"options\", []) if o.get(\"label\")]
    return labels[:1]  # default: first option

answers = {}
for q in ti.get(\"questions\", []):
    picked = [l for l in choose(q) if l]
    if not picked:
        sys.exit(0)  # could not decide: leave it to the terminal
    answers[q[\"question\"]] = \", \".join(picked) if q.get(\"multiSelect\") else picked[0]

ti[\"answers\"] = answers
print(json.dumps({\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\",
                  \"decision\": {\"behavior\": \"allow\", \"updatedInput\": ti}}}))
"
