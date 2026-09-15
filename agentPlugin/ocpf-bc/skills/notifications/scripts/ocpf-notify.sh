#!/bin/sh
# OCPF "your turn" notification for macOS and Linux (from the ocpf-bc plugin's notifications skill).
#
# An AI tool's hook runs it when the agent finishes a turn, asks a question, or waits for an
# approval, with the kinds the developer chose at intake (ALL ALONG → Notifications). Nothing is
# installed; it uses what the operating system already has.
#
# Usage: sh scripts/ocpf-notify.sh [sound] [desktop] [message...]
#   sh scripts/ocpf-notify.sh sound
#   sh scripts/ocpf-notify.sh sound desktop "Your turn: the agent finished"
#
#   sound    a short system sound (macOS afplay; Linux paplay or canberra-gtk-play; else the bell)
#   desktop  a desktop notification on Linux (notify-send). Not on macOS: a banner raised from a
#            script opens Script Editor when clicked, so the framework never offers it there.
# With neither, it plays the sound.
#
# Hook input on stdin is read and discarded, and everything runs in the background, so the calling
# tool never waits. Always exits 0: a notification that can't be shown must never interrupt the
# agent.

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

[ -t 0 ] || cat >/dev/null 2>&1

run() { "$@" >/dev/null 2>&1 </dev/null & }
bell() { printf '\a' >/dev/tty 2>/dev/null; }

case "$(uname -s)" in
  Darwin)
    [ $sound -eq 1 ] && run afplay /System/Library/Sounds/Glass.aiff
    ;;
  Linux)
    if [ $sound -eq 1 ]; then
      if command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
        run paplay /usr/share/sounds/freedesktop/stereo/complete.oga
      elif command -v canberra-gtk-play >/dev/null 2>&1; then
        run canberra-gtk-play -i complete
      else
        bell
      fi
    fi
    if [ $desktop -eq 1 ]; then
      if command -v notify-send >/dev/null 2>&1; then
        run notify-send "OCPF BC agent — $(basename "$PWD")" "$message"
      else
        bell
      fi
    fi
    ;;
  *)
    bell
    ;;
esac
exit 0
