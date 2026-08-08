#!/bin/bash
# Save the current kitty session using kitty's own serialization.
# Requires: allow_remote_control socket-only, listen_on unix:/tmp/kitty-*
#
# Socket selection, in order:
#   1. $KITTY_LISTEN_ON — kitty exports this to processes it launches, and
#      it names THIS instance. Always correct when present.
#   2. a scan of /tmp, filtered to sockets whose pid is still alive.
#
# The previous version was `ls /tmp/kitty-[0-9]* | head -1`, which sorts
# lexically (kitty-1234 sorts before kitty-999), never checked liveness, and
# hid every failure behind 2>/dev/null. With one OS window it was always
# right; with two it saved an arbitrary one, and a crashed instance's stale
# socket would win forever.
set -uo pipefail

SESSION_FILE="$HOME/.config/kitty/last-session.kitty"

socket=""
if [ -n "${KITTY_LISTEN_ON:-}" ]; then
    socket="$KITTY_LISTEN_ON"
else
    for candidate in /tmp/kitty-[0-9]*; do
        [ -S "$candidate" ] || continue
        pid="${candidate##*-}"
        if kill -0 "$pid" 2>/dev/null; then
            socket="unix:$candidate"
            break
        fi
    done
fi

if [ -z "$socket" ]; then
    echo "save-session: no live kitty socket found" >&2
    exit 1
fi

if ! kitty @ --to "$socket" action save_as_session --save-only "$SESSION_FILE"; then
    echo "save-session: kitty @ failed against $socket" >&2
    exit 1
fi
