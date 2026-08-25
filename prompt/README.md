# cship · Gruvbox Dark Hard

A four-line [Claude Code](https://claude.com/claude-code) statusline built on
[cship](https://github.com/stephenleo/cship) ≥ 1.8.1, themed on the Gruvbox
Dark Hard palette, with a matching [Starship](https://starship.rs) prompt
config that cship reuses for its first line.

Both files live in this directory: `cship.toml` and `starship.toml`.

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ calliope on main [!?⇡] via v24.16.0                                                                │  1 · Starship passthrough
│ Fable 5  high  ↳ code                                                                       30m50s │  2 · identity        ⇥ duration
│ █████░░░░░░░ 43%  43%(393k/1000k)  $3.42  +470 -122    5h 34% → Fri 4:00 AM   7d 72% → Tue 1:00 AM │  3 · metrics         ⇥ usage windows
│ opus 12%   sonnet 4%   cowork 0%                                                                   │  4 · per-model burn (collapses when absent)
└────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

(Icons omitted above — every module carries a Nerd Font glyph; see
[Glyphs](#glyphs). Box abridged to 100 columns — real output pads to your
terminal width.)

## What's in the layout

- **Line 1** — Starship passthrough: directory, git branch/status, runtime
  versions. Shares `starship.toml` with your shell prompt.
- **Line 2** — model (per-family colour), reasoning effort (per-level colour),
  active agent; session duration right-aligned via `$fill`.
- **Line 3** — 12-cell context bar, absolute token usage `43%(393k/1000k)`,
  session cost, lines added/removed; 5-hour and 7-day usage windows
  right-aligned, each with its absolute local reset time (`72% → Tue 1:00 AM`).
- **Line 4** — per-model 7-day burn (opus / sonnet / cowork). cship drops
  fully-empty lines, so this row costs nothing when the OAuth usage API has
  no data.

Warn/critical thresholds are wired throughout: context 40/70 %, cost $2/$5,
usage windows 70/90 % — gold at warn, bold red at critical.

## Why the layout is shaped this way

cship is a **layout renderer, not a data source**. Claude Code pipes session
JSON to it on every refresh, and two data paths feed the result:

- **stdin** — `rate_limits`, cost, context, model. Always present, never fails.
  The 5h/7d windows ride here.
- **the OAuth API** — per-model burn and account info. Can fail, and can hang.

That split is the design, not an accident: the reliable data anchors the
layout, and everything fed by the flaky path is confined to line 4, which cship
drops entirely when it is empty. A failed fetch costs a row, never a broken
row. Two consequences worth knowing before filing a bug against it:

- **Line 4 is often empty from a plain shell** — "credential present but API
  fetch failed" is the normal case there, and `cship explain` can hang for
  minutes on that same fetch. Transient, not misconfiguration.
- **Below roughly 100 columns the metrics line's content floor exceeds the
  render target**, so it overflows however `width` is set. Nothing to fix; a
  reason not to run the statusline in a narrow window.

## Install

```sh
cargo install cship        # or the install script from the cship README
```

Then deploy the two configs. In a clone of this tree, that is `./bin/bootstrap`,
which symlinks them into `~/.config/` along with everything else here. Existing
plain files are backed up before being replaced by a symlink — `ln -s` itself
would refuse to overwrite them, but `bootstrap` handles that for you.

Wire it into `~/.claude/settings.json`:

```json
{
  "statusLine": { "type": "command", "command": "cship" }
}
```

Requires a Nerd Font (built against FiraCode Nerd Font Mono).

## Tuning

- **Terminal width** — Claude Code historically passed no terminal width to
  statusline commands ([claude-code#22115](https://github.com/anthropics/claude-code/issues/22115),
  closed mid-2026). cship 1.8.1 doesn't consume a width field yet — it
  recovers the width best-effort from an ancestor TTY, falling back to
  `$COLUMNS`, then to `width` in `cship.toml`. **Set `width` to your own
  terminal's column count**; it ships at 129, which is a last-resort fallback
  tuned for one window, not a recommendation. It is also coupled to kitty's
  `initial_window_width`, so changing one without the other makes the
  right-alignment ragged.
- **Account labels** — the `[cship.account]` module ships **disabled**: it
  reads only the default keychain credential, so multi-account
  `CLAUDE_CONFIG_DIR` setups always see the default account
  ([cship#194](https://github.com/stephenleo/cship/issues/194)). Re-enable it
  and fill in `[cship.account.labels]` if you run a single account.
- **Schema** — the config declares
  `"$schema" = 'https://cship.dev/config-schema.json'`, so editors with a
  TOML LSP (Taplo, even-better-toml) validate and autocomplete it.

## Glyphs

All icons are Nerd Font glyphs: microchip (model), speedometer (effort),
account (account module, disabled), dollar (cost), clock (duration),
hourglass (5h), calendar (7d), cube / globe / users (per-model), bolt
(oauth), money (extra usage).

> [!warning] Some tooling silently flattens these glyphs into spaces
> Private-use-area codepoints (U+E000–F8FF, and the supplementary plane at
> U+F0000+) get replaced with spaces by some editors and formatters on rewrite.
> The file still _renders_ with correct widths, because a space fills the same
> cell — so the loss is invisible until you go looking for the icons. If you
> edit `cship.toml`, check the icons are still there afterwards.

## Palette — Gruvbox Dark Hard

| Role           | Hex       |
| -------------- | --------- |
| background     | `#1d2021` |
| aqua           | `#8ec07c` |
| green          | `#b8bb26` |
| gold (warn)    | `#fabd2f` |
| red (critical) | `#fb4934` |
| foreground     | `#ebdbb2` |
| blue           | `#83a598` |
| purple         | `#d3869b` |
| orange         | `#fe8019` |

Model families: Fable `#8ec07c` · Opus `#83a598` · Sonnet `#d3869b` ·
Haiku `#b8bb26`.

## License

MIT
