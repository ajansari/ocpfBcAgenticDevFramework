#!/bin/sh
# OCPF "your turn" notification for macOS and Linux (from the ocpf-bc plugin's notifications skill).
#
# An AI tool's hook runs it when the agent finishes a turn, asks a question, or waits for an
# approval, with the kinds the developer chose at intake (ALL ALONG -> Notifications). Nothing is
# installed; it uses what the operating system and terminal already have.
#
# Usage: sh scripts/ocpf-notify.sh [sound] [desktop] [message...]
#   sh scripts/ocpf-notify.sh sound
#   sh scripts/ocpf-notify.sh sound desktop "Your turn: the agent finished"
#
#   sound    a short system sound: macOS afplay; Linux paplay or canberra-gtk-play; otherwise the
#            terminal bell, emitted by Claude Code.
#   desktop  the terminal's own notification in iTerm2, WezTerm, Ghostty, Warp, or Kitty, emitted by
#            Claude Code; otherwise notify-send on Linux. Never a banner raised from a script on
#            macOS: clicking one opens Script Editor.
# With neither, it plays the sound.
#
# Terminal notifications and the bell are printed as Claude Code hook output
# ({"terminalSequence": ...}), because hooks have no terminal of their own. Hook input on stdin is
# read and discarded, sounds play in the background, and it always exits 0: a notification that
# can't be shown must never interrupt the agent.

sound=0; desktop=0
while [ $# -gt 0 ]; do
  case "$1" in
    sound) sound=1; shift ;;
    desktop) desktop=1; shift ;;
    *) break ;;
  esac
done
[ $sound -eq 1 ] || [ $desktop -eq 1 ] || sound=1
message="${*:-Your turn: the agent is waiting for you}"
title="OCPF BC agent"

[ -t 0 ] || cat >/dev/null 2>&1

run() { "$@" >/dev/null 2>&1 </dev/null & }
# Terminal text can't carry control characters, quotes, backslashes, or the OSC separator.
msg="$(printf '%s' "$message" | tr -d '\000-\037";\\')"
seq=""

if [ $desktop -eq 1 ]; then
  case "${TERM_PROGRAM:-}" in
    iTerm.app|WezTerm) seq="${seq}\\u001b]9;${title}: ${msg}\\u0007" ;;
    ghostty|WarpTerminal) seq="${seq}\\u001b]777;notify;${title};${msg}\\u0007" ;;
    *)
      if [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = "xterm-kitty" ]; then
        seq="${seq}\\u001b]99;;${title}: ${msg}\\u001b\\\\"
      elif [ "$(uname -s)" = "Linux" ] && command -v notify-send >/dev/null 2>&1; then
        run notify-send "$title - $(basename "$PWD")" "$msg"
      fi
      ;;
  esac
fi

if [ $sound -eq 1 ]; then
  case "$(uname -s)" in
    Darwin)
      if command -v afplay >/dev/null 2>&1; then run afplay /System/Library/Sounds/Glass.aiff; else seq="${seq}\\u0007"; fi
      ;;
    Linux)
      if command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
        run paplay /usr/share/sounds/freedesktop/stereo/complete.oga
      elif command -v canberra-gtk-play >/dev/null 2>&1; then
        run canberra-gtk-play -i complete
      else
        seq="${seq}\\u0007"
      fi
      ;;
    *) seq="${seq}\\u0007" ;;
  esac
fi

[ -n "$seq" ] && printf '{"terminalSequence":"%s"}\n' "$seq"
exit 0
