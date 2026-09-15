#!/bin/sh
# OCPF turn notification for macOS and Linux (from the ocpf-bc plugin's notifications skill).
#
# Shows a desktop notification so the developer knows the ball is in their court. An AI tool's hook
# runs it when the agent finishes a turn, asks a question, or needs an approval. Nothing is
# installed; it uses what the operating system already has.
#
# Usage: sh scripts/ocpf-notify.sh [message]
#   sh scripts/ocpf-notify.sh "Your turn: the agent finished"
#
# Hook input on stdin is read and discarded, so the calling tool never blocks. Always exits 0: a
# notification that can't be shown must never interrupt the agent.

message="${1:-Your turn: the agent is waiting for you}"
title="OCPF BC agent"
project="$(basename "$PWD")"

# Drain any hook input without waiting on an interactive terminal.
[ -t 0 ] || cat >/dev/null 2>&1

case "$(uname -s)" in
  Darwin)
    # Single quotes and backslashes can't break out of the AppleScript string.
    esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
    osascript -e "display notification \"$(esc "$message")\" with title \"$(esc "$title")\" subtitle \"$(esc "$project")\" sound name \"Glass\"" >/dev/null 2>&1 \
      || printf '\a' >/dev/tty 2>/dev/null
    ;;
  Linux)
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$title — $project" "$message" >/dev/null 2>&1 || printf '\a' >/dev/tty 2>/dev/null
    else
      printf '\a' >/dev/tty 2>/dev/null
    fi
    ;;
  *)
    printf '\a' >/dev/tty 2>/dev/null
    ;;
esac
exit 0
