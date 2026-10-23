# Claude Code hooks recipes

Small, copy-paste hook scripts for [Claude Code](https://code.claude.com/docs/en/hooks) on macOS. Each one is a single shell file with no dependencies beyond `python3` (ships with macOS). Tested on Claude Code 2.1.283.

| Recipe | Hook event | What it does |
|---|---|---|
| [answer-ask-user-question.sh](recipes/answer-ask-user-question.sh) | `PermissionRequest` | Answers `AskUserQuestion` from the hook via `updatedInput.answers` (no terminal prompt) |
| [stop-notify-macos.sh](recipes/stop-notify-macos.sh) | `Stop` | macOS notification when a turn finishes |
| [notify-phone-ntfy.sh](recipes/notify-phone-ntfy.sh) | `Notification` | Pushes permission prompts and questions to your phone through [ntfy](https://ntfy.sh) |
| [keep-awake-while-session.sh](recipes/keep-awake-while-session.sh) | `SessionStart` / `SessionEnd` | `caffeinate` for the lifetime of the session, cleaned up on exit |
| [list-leftovers.sh](recipes/list-leftovers.sh) | `SessionEnd` | Lists (optionally kills) processes the session left behind |

## Install

Copy a script somewhere on your PATH-free location (for example `~/.claude/hooks/`), make it executable, and register it in `~/.claude/settings.json`. [settings.example.json](settings.example.json) shows all five wired up.

```sh
mkdir -p ~/.claude/hooks
cp recipes/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

Hooks run with your user's permissions. Read a script before you install it.

## Notes from testing

- **`allow` alone does not answer `AskUserQuestion`.** If an approval hook returns `{"behavior":"allow"}` without `updatedInput.answers`, the question stays open and the session keeps waiting. The answer has to be in `updatedInput` (see the first recipe and [this write-up](https://dev.to/dawonlee/you-can-answer-claude-codes-askuserquestion-from-a-hook-and-from-your-phone-1ddn)).
- **Version warning for `answer-ask-user-question.sh`.** After Claude Code 2.1.300, `updatedInput` validation in `PermissionRequest` hooks is stricter, so this approach may not work. It has only been verified on 2.1.283. On newer versions, look at a `PreToolUse` route instead.
- A `PermissionRequest` hook blocks until it returns. If you want to answer from somewhere else (a phone, a menu bar app), the hook has to wait for that answer and give up before the hook timeout so the terminal prompt still works.
- `caffeinate` only prevents idle sleep. Closing a MacBook's lid without an external display still sleeps it; that needs `pmset disablesleep` (and remembering to turn it back off).

## Related

I build [Lidnight](https://lidnight.app/en/), a Mac menu bar app that does the phone-answer, lid-closed and leftover-cleanup parts of this for Claude Code and Codex without the relay setup. The recipes here work on their own; you don't need it.

MIT.

---

## 한국어

Claude Code 훅 스크립트 모음(macOS). 각 파일은 `python3`만 쓰는 셸 스크립트 하나입니다.

- `answer-ask-user-question.sh`: `AskUserQuestion`에 훅으로 답하기(`updatedInput.answers`). `allow`만 돌려주면 질문이 안 끝납니다.
- `stop-notify-macos.sh`: 턴이 끝나면 Mac 알림.
- `notify-phone-ntfy.sh`: 승인 요청·질문을 ntfy로 휴대폰에 푸시.
- `keep-awake-while-session.sh`: 세션 동안 `caffeinate`(뚜껑 닫힘은 못 막음).
- `list-leftovers.sh`: 세션이 끝난 뒤 남은 프로세스 목록(옵션으로 종료).

설치: `recipes/*.sh`를 `~/.claude/hooks/`에 복사하고 실행 권한을 준 뒤 `settings.example.json`처럼 등록합니다.

## 日本語

Claude Code 用フックスクリプト集（macOS）。各ファイルは `python3` だけを使うシェルスクリプト 1 つです。

- `answer-ask-user-question.sh`: `AskUserQuestion` にフックで答える（`updatedInput.answers`）。`allow` だけでは質問は終わりません。
- `stop-notify-macos.sh`: ターン終了時に Mac 通知。
- `notify-phone-ntfy.sh`: 承認待ちや質問を ntfy でスマホに通知。
- `keep-awake-while-session.sh`: セッション中 `caffeinate`（蓋を閉じるスリープは防げません）。
- `list-leftovers.sh`: セッション終了後に残ったプロセスを一覧（オプションで終了）。

インストール: `recipes/*.sh` を `~/.claude/hooks/` にコピーして実行権限を付け、`settings.example.json` のように登録します。
