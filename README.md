# dotfiles · public

A macOS terminal and editor setup: kitty, zsh, tmux, starship, the cship Claude
Code statusline, Zed and Sublime Text. Generated from a private dotfiles repo,
so what is here is the whole shareable surface — nothing is elided from within
a file (the one generated file, `manifest.tsv`, is the source manifest's public
rows), and nothing beyond this is coming.

**Want one piece, not the setup?** A directory here that carries its own
`README.md` and `install.sh` can be taken alone: the script copies that
directory's files into your own config — copies, never symlinks — wires the
one entry that makes the tool read them, and touches nothing else; its page
says exactly what. Today that is [`prompt/`](prompt/README.md), the Claude
Code statusline. Everything else installs as one setup, through
`bin/bootstrap` under Install below.

> This repo was called **`osaka-jade`** until 15-08-2026, after the kitty
> palette it shipped at the time. The name pinned a theme choice that is
> explicitly allowed to change, and asserted a unification the setup rejects —
> the editors run a different scheme on purpose. GitHub redirects the old URL.
> The anticipated change has since happened: the terminal palette moved on
> 25-08-2026, and the repo name did not have to move with it.

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

The private source repo goes one step further: a written statement of taste
with a machine-checkable half that its `dot-doctor` asserts against the
applications' live config on every run, and a record of what each application
cannot reach. That machinery is not here. Its spec is one file and names the
author's infrastructure beside the taste, so it stays private by ruling rather
than by oversight. The `dot-doctor` shipped here runs the manifest rows and
the semantic checks; the preference section is simply absent without its
spec.

## What you get

| Directory         | Holds                                                                                                                                                                                                                                                                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `shell/`          | zsh in three files split by cost — `zshenv` (every shell), `zprofile` (per login), `zshrc` (interactive). History that searches by real prefix, mise-managed runtimes, fzf + zoxide + eza + atuin (its config under `atuin/`), autosuggestions and syntax highlighting, an `inputrc` for the readline tools, and an empty `hushlogin` so a new tab opens at the prompt rather than under the login banner |
| `terminal/kitty/` | kitty — the palette as its own included `current-theme.conf`, the typeface with ligatures, the caret, copy-on-select, scrollback paged through `bat`, a silent bell, and the click half of the shell seam: `open-actions.conf` plus a `mime.types` for the extensions Python's table gets wrong, and `choose-files.conf` so the keyboard file picker agrees with the shell about which files exist |
| `terminal/tmux/`  | tmux for SSH — true colour through the overrides, mouse on, a deep history, resurrect/continuum                                                                                                                                                                                                                                                              |
| `terminal/bat/`   | one line, so `bat` rides the terminal's palette instead of carrying its own                                                                                                                                                                                                                                                                                 |
| `terminal/ncdu/`  | one line, so ncdu draws in the terminal's palette                                                                                                                                                                                                                                                                                                          |
| `prompt/`         | **Stands alone — take it by itself.** The cship Claude Code statusline, with starship on the terminal palette doubling as its line 1. `prompt/README.md` is its own page and `prompt/install.sh` its own installer    |
| `editor/zed/`     | Zed — `settings.json`, a `keymap.json` on a JetBrains base, `tasks.json`                                                                                                                                                                                                                                                                                    |
| `editor/sublime/` | Sublime Text with a **vendored** light colour scheme (its upstream is abandoned) and Terminus configured to match                                                                                                                                                                                                                                             |
| `git/`            | `gitconfig` — rebase on pull, auto-set upstream, prune on fetch, `rerere` — and the global `ignore`. Identity is not here; `bootstrap` asks for it                                                                                                                                                                                                       |
| `gh/`             | `config.yml` — the CLI's own preferences                                                                                                                                                                                                                                                                                                                    |
| `ripgrep/`        | the default flags — hidden files in, `.git` out, smart case, matches that open in the editor on click                                                                                                                                                                                                                                                       |
| `ssh/`            | `config.example` only. The real config names live hosts and is private — this is the ControlMaster/tunnel pattern, sanitised                                                                                                                                                                                                                                |
| `bin/`            | `bootstrap`, a Keychain-reading stdio wrapper for the Context7 MCP server, and the two verbs — `dot-apply` and `dot-doctor`                                                                                                                                                                                                                                  |

Not included, because it is not shareable: the IntelliJ IDEA config (several of
its option files name an employer, so the whole tree is treated as private),
the real SSH config, local git identity, personal scripts, and the preference
machinery described above.

## Install

```bash
git clone https://github.com/gati3478/dotfiles-public ~/dotfiles-public
cd ~/dotfiles-public && ./bin/bootstrap
```

`bootstrap` asks for your name and email, writes them to `~/.gitconfig.local`,
rewrites the one path kitty's config language cannot template, then symlinks
the rest into place. Existing plain files are backed up before being replaced by
a symlink; the **copied** files — Sublime's, kitty's theme file, gh's config —
are overwritten directly, so back those up yourself if you have already
customised them.

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
