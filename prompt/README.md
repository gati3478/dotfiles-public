# cship · Gruvbox Dark Hard

A three-line [Claude Code](https://claude.com/claude-code) statusline built on
[cship](https://github.com/stephenleo/cship) ≥ 1.8.1, themed on the Gruvbox
Dark Hard palette, with a matching [Starship](https://starship.rs) prompt
config that cship reuses for its first line.

Both files live in this directory: `cship.toml` and `starship.toml`.

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ calliope on main [!?⇡] via v24.16.0                                                                │  1 · Starship passthrough
│ Fable 5  high  ↳ code                                                                       30m50s │  2 · identity        ⇥ duration
│ █████░░░░░░░ 43%  43%(393k/1000k)  $3.42  +470 -122    5h 34% → Fri 4:00 AM   7d 72% → Tue 1:00 AM │  3 · metrics         ⇥ usage windows
└────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

(Icons omitted above — every module carries a Nerd Font glyph; see
[Glyphs](#glyphs). Box abridged to 100 columns — real output pads to your
terminal width.)

## What's in the layout

- **Line 1** — Starship passthrough: directory, git branch, in-progress git
  operation, git status, runtime versions (Python, Java, Kotlin, Gradle, Rust,
  Node). Each module's look comes from `starship.toml`, shared with your shell
  prompt; which modules appear is this file's own list — starship's `format`
  minus its shell-only modules — because cship runs `starship module <name>`
  per token and never reads `format`.
- **Line 2** — model (per-family colour), reasoning effort (per-level colour),
  active agent; session duration right-aligned via `$fill`.
- **Line 3** — 12-cell context bar, absolute token usage `43%(393k/1000k)`,
  session cost, lines added/removed; 5-hour and 7-day usage windows
  right-aligned, each with its absolute local reset time (`72% → Tue 1:00 AM`).

Warn/critical thresholds are wired throughout: context 40/70 %, cost $2/$5,
usage windows 70/90 % — gold at warn, bold red at critical.

## Why the layout is shaped this way

cship is a **layout renderer, not a data source**. Claude Code pipes session
JSON to it on every refresh, and two data paths exist:

- **stdin** — `rate_limits`, cost, context, model. Always present, never fails.
  Everything shown here rides on it, including the 5h/7d windows.
- **the OAuth API** — per-model burn, extra usage, account info. cship reads
  the default keychain credential for it regardless of `CLAUDE_CONFIG_DIR`
  ([cship#194](https://github.com/stephenleo/cship/issues/194)), so in a
  multi-account setup every field it feeds belongs to the default account.

This layout renders nothing from the second path, with one exception it
cannot avoid: until the session's first API response, `rate_limits` is not on
stdin yet and the 5h/7d figures come from the OAuth path for a few seconds.
A per-model line existed
until 02-09-2026 and was dropped for exactly that reason; restore it
(`$cship.usage_limits.per_model` as a fourth line, plus `opus_format` /
`sonnet_format` / `cowork_format`) once #194 is fixed or if you run one
account. cship still performs the fetch every `ttl` seconds; a failure costs
one render a 2 s stall and then a 30 s cooldown, never a broken row. One more
thing worth knowing before filing a bug:

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

- **Terminal width** — cship 1.8.1 resolves the width for `$fill` in this
  order: the controlling TTY of an ancestor process, then `$COLUMNS`, then
  `width` in `cship.toml`, then 80. Claude Code sets `COLUMNS` and `LINES`
  before running the statusline command (it passed no width until
  [claude-code#22115](https://github.com/anthropics/claude-code/issues/22115)
  closed in May 2026), so in a real terminal the first two always answer and
  `width` is never read. It matters only where neither exists — Windows, the
  web and desktop apps — and there it should be your terminal's column count.
  It ships at 129; resizing the window does not misalign anything.
- **Right margin** — `width_offset` is the number of columns Claude Code keeps
  around the statusline. cship defaults to 3; Claude Code 2.1.258 keeps 4, and
  with 3 every right-aligned line lost its last cell to an ellipsis. It ships
  at 4. A trailing `…` on the right after a Claude Code update means it needs
  re-measuring.
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
hourglass (5h), calendar (7d).

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
