# preen

A macOS terminal and editor setup: kitty, zsh, tmux, starship, the cship Claude
Code statusline, Zed and Sublime Text. Generated from a private dotfiles repo,
so what is here is the whole shareable surface — nothing is elided from within
a file (the one generated file, `manifest.tsv`, is the source manifest's public
rows), and nothing beyond this is coming.

**Want one piece, not the setup?** A directory here with its own `README.md`
and `install.sh` can be taken alone: the script copies that directory's files
into your config — copies, never symlinks — and wires the one entry that
makes the tool read them; its page says exactly what it touches, and it
touches nothing it does not print first. Today that is
[`prompt/`](prompt/README.md), the Claude Code statusline, and
[`terminal/kitty/`](terminal/kitty/README.md), the terminal's look. Both
installers fetch one shared helper, `lib/install.sh`, the way they fetch the
configs. Everything else installs as one setup, through `bin/bootstrap` under
Install below.

> This repo was **`osaka-jade`** until 15-08-2026 — a name that pinned a
> palette allowed to change, and it changed — and **`dotfiles-public`** until
> 17-09-2026. *Preen*: to groom to your own standard, which is what the
> tooling does. GitHub redirects both old URLs.

## The model

**One table drives install and verification.** `manifest.tsv` maps each file
here to its live path and says whether the row is a symlink or a copy.
`bin/dot-apply` installs from it; `bin/dot-doctor` checks against it. There is
no second list, so "installed" and "checked" read the same row.

**`link` or `copy`, decided by who writes the file.** Where an application only
reads its config, the live file is a symlink and the repo file _is_ the config.
Where the application rewrites its own config — Sublime, gh, kitty for its
theme file — the row is a copy, because a symlink would be replaced by a plain
file the first time it saved.

**Themes are a family, not one scheme.** Dark where code runs, light where it
is read, the same palette family from opposite poles, the typeface shared
throughout. The names are in the config files — kitty's theme is its own
included file, so a swap touches one file — and `prompt/README.md` carries the
statusline's palette table.

The taste is also written down as assertions. `preferences.toml` states each
preference once — what, and why — with rows a checker reads off the
applications' _live_ config, and records what each application cannot reach.
`./bin/dot-doctor --taste` runs them against yours. It is the author's taste,
so the plain `dot-doctor` never asserts it: it checks the manifest rows and
the semantic checks, and a correct setup of your own is not failed over
someone else's preferences.

**Comments here name things that are not here.** These files are the private
repo's own, published unedited, so their comments cite its pages
(`docs/preferences.md`, `docs/traps.md`, `decisions.md`), its tooling
(`dot-publish`, `dot-pull`, `publish/deny.txt`) and its internal task numbers.
Nothing in this repository reads any of them and nothing breaks without them —
`dot-doctor --taste` notes the one it would cross-check against, the prose
half of the taste, and carries on — they are context for the author, not
instructions for you. Where one appeared
in a message meant for *you* to act on, that message has been rewritten.
`prompt/README.md` says the same about `cship.toml` and `starship.toml` for
anyone taking that directory alone.

## What you get

| Directory         | Holds                                                                                                                                                                                                                                                                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `shell/`          | zsh in three files split by cost — `zshenv` (every shell), `zprofile` (per login), `zshrc` (interactive). History that searches by real prefix, mise-managed runtimes, fzf + zoxide + eza + atuin (its config under `atuin/`), autosuggestions and syntax highlighting, an `inputrc` for the readline tools, and an empty `hushlogin` so a new tab opens at the prompt rather than under the login banner |
| `terminal/kitty/` | **Stands alone — take it by itself.** kitty — the palette as its own included `current-theme.conf`, the typeface with ligatures, the caret, copy-on-select, scrollback paged through `bat`, a silent bell, and the click half of the shell seam: `open-actions.conf` plus a `mime.types` for the extensions Python's table gets wrong, and `choose-files.conf` so the keyboard file picker agrees with the shell about which files exist. `terminal/kitty/README.md` is its own page and `terminal/kitty/install.sh` its own installer |
| `terminal/tmux/`  | tmux for SSH — true colour through the overrides, mouse on, a deep history, resurrect/continuum                                                                                                                                                                                                                                                              |
| `terminal/bat/`   | one line, so `bat` rides the terminal's palette instead of carrying its own                                                                                                                                                                                                                                                                                 |
| `terminal/ncdu/`  | one setting, so ncdu draws in the terminal's palette                                                                                                                                                                                                                                                                                                          |
| `prompt/`         | **Stands alone — take it by itself.** The cship Claude Code statusline, with starship on the terminal palette doubling as its line 1. `prompt/README.md` is its own page and `prompt/install.sh` its own installer    |
| `editor/zed/`     | Zed — `settings.json`, a `keymap.json` on a JetBrains base, `tasks.json`                                                                                                                                                                                                                                                                                    |
| `editor/sublime/` | Sublime Text with a **vendored** light colour scheme (its upstream is abandoned) and Terminus configured to match                                                                                                                                                                                                                                             |
| `git/`            | `gitconfig` — rebase on pull, auto-set upstream, prune on fetch, `rerere` — and the global `ignore`. Identity is not here; `bootstrap` asks for it                                                                                                                                                                                                       |
| `gh/`             | `config.yml` — the CLI's own preferences                                                                                                                                                                                                                                                                                                                    |
| `ripgrep/`        | the default flags — hidden files in, `.git` out, smart case, matches that open in the editor on click                                                                                                                                                                                                                                                       |
| `mise/`           | `config.toml` — the runtime manager's global pins, a node and a python, so a shell has both without a per-project file. The shell config activates mise; this is the file it reads |
| `ssh/`            | `config` — one `Include ~/.ssh/config.local` on its first line, then the `Host *` agent line; ssh keeps the first value it reads, so your own config, moved to `config.local`, wins every line. `config.example` is the ControlMaster/tunnel pattern for that file, sanitised — the real one names live hosts and is private |
| `macos/`          | `apply.sh` — the settings System Settings owns, written with `defaults`: appearance, Dock, hot corners, Finder, trackpad, spelling, languages, screenshots, the clock, Stage Manager, Siri. **Not a manifest row and not run by `bootstrap`**: it is the author's taste for a whole Mac, applied in one go. Read it before running it; it restarts the Dock and Finder, and prints the one root step rather than running it |
| `bin/`            | `bootstrap`, the two verbs — `dot-apply` and `dot-doctor` — and under `lib/` what `dot-doctor` runs: the mirror's currency fingerprint, the preference checker (`pref-check.py`, python ≥ 3.11, and the shell shim that sources it) and the live-shell probe it runs beside itself |
| `lib/`            | `install.sh` — the half the two drop-in installers share: where a piece's files come from, how a file is placed and backed up, the plan before the first write. Not run on its own |
| `preferences.toml` | the taste as assertions — each preference's `value` and `why`, and the rows that check it against live config. No manifest row: nothing deploys it, `dot-doctor --taste` reads it where it sits |

Not included, because it is not shareable: the IntelliJ IDEA config (several of
its option files name an employer, so the whole tree is treated as private),
the real SSH hosts, local git identity, personal scripts, the spec's rows
about the author's own machines, and the prose that argues each preference.

## Install

```bash
git clone https://github.com/gati3478/preen ~/preen
cd ~/preen && ./bin/bootstrap
```

`bootstrap` asks for your name and email and writes them to
`~/.gitconfig.local`, creates two empty overlays the shell config reads if you
ever fill them in (`~/.zshenv.local`, `~/.zprofile.local`), deploys every
manifest row, and finally writes `~/.config/kitty/local.conf` with the one path
kitty's config language cannot template — your home directory, which
`kitty.conf` collapses to `~` in tab titles and can only name as a literal.

**It does not modify your clone**, so `git pull` keeps working. What it does to
a file already sitting where a row goes depends on the row:

- **`link` rows.** A plain file is copied beside itself as
  `<file>.pre-dotfiles` first. A symlink is replaced and its old target
  printed, not saved — the file it pointed at is untouched.
- **`copy` rows** — Sublime's, kitty's theme file, gh's config. A plain file is
  **overwritten with no backup**, so save it yourself if you have customised
  it. A symlink is moved aside to `<file>.pre-dotfiles` rather than written
  through, which would have destroyed whatever it pointed at.

`~/.gitconfig.local` is not a manifest row and is backed up with a timestamp.

## Verifying it afterwards

```bash
./bin/dot-doctor
```

Every manifest row, then the semantic checks that survived the trip here —
several probe tools the author runs, and warn rather than fail when a tool is
absent.

## Taking everything

Fork or clone, then keep the manifest format and the two verbs. They know the
author's machine through `dot-doctor`'s semantic section, which probes the
tools the author runs and one local decision about atuin — read it and cut
what is not yours. Replace the rows with your own files, and delete every
directory you do not want along with its rows. For one piece, the paragraph
at the top of this page is the door.

MIT.
