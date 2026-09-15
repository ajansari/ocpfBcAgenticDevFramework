#!/bin/sh
# OCPF "your turn" sound for macOS and Linux (from the ocpf-bc plugin's notifications skill).
#
# Plays a short system sound so the developer hears that the ball is in their court. An AI tool's
# hook runs it when the agent finishes a turn, asks a question, or waits for an approval. It shows
# no banner, so there's nothing to click. Nothing is installed; it uses what the operating system
# already has.
#
# Usage: sh scripts/ocpf-notify.sh
#
# Hook input on stdin is read and discarded, and the sound plays in the background, so the calling
# tool never waits. Always exits 0: a sound that can't play must never interrupt the agent.

[ -t 0 ] || cat >/dev/null 2>&1

play() { "$@" >/dev/null 2>&1 </dev/null & }

case "$(uname -s)" in
  Darwin)
    play afplay /System/Library/Sounds/Glass.aiff
    ;;
  Linux)
    sound=/usr/share/sounds/freedesktop/stereo/complete.oga
    if command -v paplay >/dev/null 2>&1 && [ -f "$sound" ]; then
      play paplay "$sound"
    elif command -v canberra-gtk-play >/dev/null 2>&1; then
      play canberra-gtk-play -i complete
    else
      printf '\a' >/dev/tty 2>/dev/null
    fi
    ;;
  *)
    printf '\a' >/dev/tty 2>/dev/null
    ;;
esac
exit 0
