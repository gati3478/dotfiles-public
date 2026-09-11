#!/usr/bin/env bash
# Take this statusline alone.
#
# Copies cship.toml — and starship.toml if you say so — into ~/.config, wires
# cship into ~/.claude/settings.json, and prints what it did and what it left
# alone. Copies, never symlinks: the files become yours to tune, and nothing
# here points back at this repo afterwards.
#
# From a clone:            ./prompt/install.sh
# From the mirror, no clone:
#   curl -fsSL https://raw.githubusercontent.com/gati3478/dotfiles-public/main/prompt/install.sh | bash
#
# It asks two questions when it has a terminal to ask on. Each flag answers
# one, and with both answered (or no terminal) it asks nothing:
#   --with-starship | --no-starship       take starship.toml too — this REPLACES
#                                         your shell prompt, not only line 1
#   --account-label NAME | --no-account   what line 2 calls your account, or
#                                         hide the module in your copy
#
# Never overwrites without a timestamped backup, never touches an existing
# statusLine entry, never runs as root. Re-running with nothing changed is a
# no-op — no new backup, no rewrite.
set -euo pipefail

SOURCE_URL="${PROMPT_SOURCE:-https://raw.githubusercontent.com/gati3478/dotfiles-public/main/prompt}"
CSHIP_FLOOR="1.8.2"   # per-window usage tokens and CSHIP_ACCOUNT arrived here
REFRESH_SECONDS=60    # re-render on a timer, so the clock and windows move while idle
CONFIG_DIR="$HOME/.config"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
  echo "usage: install.sh [--with-starship | --no-starship] [--account-label NAME | --no-account]" >&2
}

with_starship=""
account_mode=""
account_label=""
while [ $# -gt 0 ]; do
  case "$1" in
    --with-starship) with_starship=yes ;;
    --no-starship)   with_starship=no ;;
    --no-account)    account_mode=hide ;;
    --account-label)
      shift
      account_label="${1:-}"
      account_mode=label
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "install.sh: unknown argument: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

if [ "$(id -u)" -eq 0 ]; then
  echo "install.sh: refusing to run as root — this installs user files" >&2
  exit 1
fi

# The label lands inside a JSON string inside a shell command line. Letters,
# digits, space, dot, underscore, dash: nothing that needs quoting in either.
label_ok() { [ -n "$1" ] && ! printf '%s' "$1" | LC_ALL=C grep -q '[^A-Za-z0-9._ -]'; }
if [ "$account_mode" = label ] && ! label_ok "$account_label"; then
  echo "install.sh: --account-label: a non-empty name of letters, digits, space, '.', '_', '-' (or say --no-account)" >&2
  exit 2
fi

# Piped from curl, stdin is the script; questions go through the terminal
# itself, if there is one.
interactive=no
if { exec 3</dev/tty; } 2>/dev/null; then
  interactive=yes
  exec 3<&-
fi
ask() { # ask <prompt>  → the line typed, possibly empty
  printf '%s' "$1" >/dev/tty
  IFS= read -r reply </dev/tty || reply=""
  printf '%s' "$reply"
}

# bash 3.2 (macOS) keeps the backslash in a `${x/#$HOME/\~}` replacement and a
# bare `~` there tilde-expands back to $HOME, so neither spelling is portable.
short() {
  case "$1" in
    "$HOME"|"$HOME"/*) printf '~%s' "${1#"$HOME"}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# ── where the configs come from ──────────────────────────────────────────────
# Beside this script when run from a clone; otherwise fetched from the mirror.
SRC=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/cship.toml" ]; then
  SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
if [ -z "$SRC" ]; then
  SRC="$WORK/src"
  mkdir -p "$SRC"
  echo "== fetching from $SOURCE_URL =="
  for f in cship.toml starship.toml; do
    if ! curl -fsSL "$SOURCE_URL/$f" -o "$SRC/$f" || [ ! -s "$SRC/$f" ]; then
      echo "install.sh: could not fetch $SOURCE_URL/$f" >&2
      exit 1
    fi
  done
  # -f already refuses a 404; this refuses a 200 that is not the file.
  grep -q '^\[cship\]' "$SRC/cship.toml" || { echo "install.sh: $SOURCE_URL/cship.toml is not a cship config" >&2; exit 1; }
fi

# ── dependencies ─────────────────────────────────────────────────────────────
echo "== dependencies =="
cship_bin="$(command -v cship 2>/dev/null || true)"
# cship's installer puts it in ~/.local/bin, cargo in ~/.cargo/bin; neither
# need be on PATH for the statusline, which is wired by absolute path below.
for candidate in "$HOME/.local/bin/cship" "$HOME/.cargo/bin/cship"; do
  if [ -z "$cship_bin" ] && [ -x "$candidate" ]; then
    cship_bin="$candidate"
  fi
done
if [ -z "$cship_bin" ]; then
  echo "cship not found. Install it first, either way:" >&2
  echo "  curl -fsSL https://cship.dev/install.sh | bash     # binary + a starter config + statusLine wiring" >&2
  echo "  cargo install cship                                 # binary only" >&2
  echo "then re-run this." >&2
  exit 1
fi
cship_version="$("$cship_bin" --version 2>/dev/null | awk '{ print $2 }')"
version_ge() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)" = "$1" ]; }
if [ -z "$cship_version" ] || ! version_ge "$cship_version" "$CSHIP_FLOOR"; then
  echo "cship $cship_version at $cship_bin — this config needs $CSHIP_FLOOR or newer" >&2
  exit 1
fi
echo "cship $cship_version at $(short "$cship_bin")"

starship_bin="$(command -v starship 2>/dev/null || true)"
if [ -n "$starship_bin" ]; then
  echo "starship $("$starship_bin" --version 2>/dev/null | head -1 | awk '{ print $2 }') at $(short "$starship_bin")"
else
  echo "starship not on PATH — line 1 of the statusline stays absent until it is; lines 2 and 3 render regardless"
fi

# settings.json is probed before anything is written, so an unreadable file
# stops the run with nothing half-done.
python3_bin="$(command -v python3 2>/dev/null || true)"
settings_state=missing
if [ -f "$SETTINGS" ]; then
  if [ -z "$python3_bin" ]; then
    settings_state=nopython
  else
    settings_state="$("$python3_bin" - "$SETTINGS" <<'PY'
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as fh:
        data = json.load(fh)
except (OSError, ValueError):
    print("invalid"); sys.exit(0)
print("present" if "statusLine" in data else "absent")
PY
)"
  fi
fi
if [ "$settings_state" = invalid ]; then
  echo "install.sh: $(short "$SETTINGS") is not valid JSON — fix it, then re-run; nothing was changed" >&2
  exit 1
fi

# ── the two questions ────────────────────────────────────────────────────────
if [ -z "$with_starship" ]; then
  with_starship=no
  if [ "$interactive" = yes ]; then
    echo
    echo "== starship =="
    echo "starship.toml here styles line 1 — and, because starship reads one file, your shell prompt."
    echo "Taking it replaces $(short "$CONFIG_DIR/starship.toml") (backed up first)."
    reply="$(ask 'Take starship.toml too? [y/N] ')"
    case "$reply" in
      y|Y) with_starship=yes ;;
    esac
  fi
fi

if [ -z "$account_mode" ]; then
  account_mode=hide
  if [ "$interactive" = yes ]; then
    echo
    echo "== account label =="
    echo "Line 2 names the account a session runs under. Left to itself the module shows the"
    echo "organisation name cship fetches, and on a personal account that is your email address."
    echo "A label here is shown instead, fetched from nowhere. Blank hides the module in your copy."
    reply="$(ask 'Label (blank = hide): ')"
    if label_ok "$reply"; then
      account_mode=label
      account_label="$reply"
    elif [ -n "$reply" ]; then
      echo "letters, digits, space, '.', '_', '-' only — hiding the module instead"
    fi
  fi
fi

# ── the copies ───────────────────────────────────────────────────────────────
# Each file is materialised as it should land, then compared with what is
# there: an identical file is left untouched, so a re-run backs up nothing.
place() { # place <materialised> <destination>
  local src="$1" dst="$2"
  if [ -d "$dst" ] && [ ! -L "$dst" ]; then
    echo "install.sh: refusing — $(short "$dst") is a directory" >&2
    exit 1
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ ! -L "$dst" ] && cmp -s "$src" "$dst"; then
      echo "unchanged       $(short "$dst")"
      return
    fi
    local bak="$dst.pre-dotfiles.$STAMP"
    mv "$dst" "$bak"                       # a symlink moves as a symlink
    echo "backed up       $(short "$dst") -> $(short "$bak")"
  fi
  cp "$src" "$dst"
  echo "copied          $(short "$dst")"
}

echo
echo "== copying =="
mkdir -p "$CONFIG_DIR"

if [ "$account_mode" = hide ]; then
  # cship's own switch for the module, inserted into YOUR copy only. awk
  # passes every other byte through, Nerd Font glyphs included.
  awk '{ print } $0 == "[cship.account]" { print "disabled = true" }' "$SRC/cship.toml" > "$WORK/cship.toml"
else
  cp "$SRC/cship.toml" "$WORK/cship.toml"
fi
place "$WORK/cship.toml" "$CONFIG_DIR/cship.toml"

if [ "$with_starship" = yes ]; then
  place "$SRC/starship.toml" "$CONFIG_DIR/starship.toml"
else
  echo "left alone      $(short "$CONFIG_DIR/starship.toml")   (say --with-starship to take it)"
fi

# ── settings.json ────────────────────────────────────────────────────────────
echo
echo "== wiring =="
command="$cship_bin"
if [ "$account_mode" = label ]; then
  # The same path cship gives a multi-account launcher: the process that
  # starts cship states the account, and cship fetches nothing for it.
  command="CSHIP_ACCOUNT='{\"organization_name\":\"$account_label\"}' $cship_bin"
fi
wired="not wired"
case "$settings_state" in
  present)
    wired="left alone — statusLine was already set"
    echo "statusLine already set in $(short "$SETTINGS") — left as it is. This config would run:"
    echo "  $command"
    ;;
  nopython)
    wired="not wired — no python3"
    echo "python3 not found, so $(short "$SETTINGS") was not edited. Add this by hand:"
    echo "  \"statusLine\": { \"type\": \"command\", \"command\": \"$command\", \"refreshInterval\": $REFRESH_SECONDS }"
    ;;
  missing)
    if [ ! -d "$CLAUDE_DIR" ]; then
      wired="not wired — no ~/.claude"
      echo "$(short "$CLAUDE_DIR") does not exist — is Claude Code installed? Once it is, add to $(short "$SETTINGS"):"
      echo "  \"statusLine\": { \"type\": \"command\", \"command\": \"$command\", \"refreshInterval\": $REFRESH_SECONDS }"
    else
      printf '{}\n' > "$SETTINGS"
      settings_state=created
      echo "created         $(short "$SETTINGS")"
    fi
    ;;
esac
if [ "$settings_state" = absent ]; then
  cp "$SETTINGS" "$SETTINGS.pre-dotfiles.$STAMP"
  echo "backed up       $(short "$SETTINGS") -> $(short "$SETTINGS.pre-dotfiles.$STAMP")"
fi
if [ "$settings_state" = absent ] || [ "$settings_state" = created ]; then
  "$python3_bin" - "$SETTINGS" "$command" "$REFRESH_SECONDS" <<'PY'
import json, sys
path, command, refresh = sys.argv[1], sys.argv[2], int(sys.argv[3])
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)
data["statusLine"] = {"type": "command", "command": command, "refreshInterval": refresh}
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY
  wired="wired — statusLine runs $(short "$cship_bin") every $REFRESH_SECONDS s"
  echo "wired           $(short "$SETTINGS")"
fi

# ── what happened ────────────────────────────────────────────────────────────
echo
echo "== summary =="
echo "cship.toml      $(short "$CONFIG_DIR/cship.toml")"
if [ "$with_starship" = yes ]; then
  echo "starship.toml   $(short "$CONFIG_DIR/starship.toml") — your shell prompt too, from the next shell"
else
  echo "starship.toml   left alone"
fi
case "$account_mode" in
  hide)  echo "account         hidden in your copy (disabled = true under [cship.account])" ;;
  label) echo "account         \"$account_label\", via CSHIP_ACCOUNT in the statusLine command" ;;
esac
echo "settings.json   $wired"
echo
echo "Next: start claude. The statusline appears after the first response. Icons need a Nerd Font in the terminal."
