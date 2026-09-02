# dotfiles · public

A macOS terminal and editor setup: kitty, zsh, tmux, starship, the cship Claude
Code statusline, Zed and Sublime Text. Generated from a private dotfiles repo,
so what is here is the whole shareable surface — nothing is elided from within a
file, and nothing beyond this is coming.

> This repo was called **`osaka-jade`** until 15-08-2026, after the kitty
> palette it ships. The name asserted a unification the setup deliberately
> rejects — the editors run a different scheme on purpose — and it pinned a
> theme choice that is explicitly allowed to change. GitHub redirects the old
> URL. That anticipated change has since happened: the terminal moved to
> Gruvbox Dark Hard on 25-08-2026, and the repo name didn't have to move with it.

## What you get

| Directory         | Holds                                                                                                                                                                                                                                        |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `shell/`          | zsh in three files split by cost — `zshenv` (every shell), `zprofile` (per login), `zshrc` (interactive). History that searches by real prefix, mise-managed runtimes, fzf + zoxide + eza + atuin, autosuggestions and syntax highlighting, and an empty `hushlogin` so a new tab opens at the prompt rather than under macOS's login banner |
| `terminal/kitty/` | kitty on the Gruvbox Dark Hard palette (the theme is its own `current-theme.conf`, included), FiraCode Nerd Font Mono with ligatures, an underline caret, copy-on-select, 50k scrollback paged through `bat`, plus a session-save script |
| `terminal/tmux/`  | tmux for SSH — true colour through the overrides, mouse on, 200k history, resurrect/continuum                                                                                                                                                |
| `terminal/bat/`   | one line: the `ansi` theme, so `bat` follows the terminal palette instead of fighting it                                                                                                                                                     |
| `prompt/`         | starship in Gruvbox Dark Hard, doubling as line 1 of the statusline, and the cship config beside it — see `prompt/README.md`                                                                                                                        |
| `editor/zed/`     | Zed on Gruvbox Light with the JetBrains base keymap: `settings.json`, `keymap.json`, `tasks.json`                                                                                                                                            |
| `editor/sublime/` | Sublime Text with a **vendored** gruvbox-light-hard colour scheme (its upstream is abandoned) and Terminus configured to match                                                                                                               |
| `git/`            | `gitconfig` — rebase on pull, auto-set upstream, prune on fetch, `rerere`. Identity is not here; `bootstrap` asks for it                                                                                                                     |
| `ssh/`            | `config.example` only. The real config names live hosts and is private — this is the ControlMaster/tunnel pattern, sanitised                                                                                                                 |
| `bin/`            | `bootstrap`, a Keychain-reading stdio wrapper for the Context7 MCP server, and the two verbs below — `dot-apply` and `dot-doctor`                                                                                                            |

Not included, because it is not shareable: the IntelliJ IDEA config (several of
its option files name an employer, so the whole tree is treated as private even
though most individual files are clean), the real SSH config, local git
identity, and personal scripts.

## Install

```bash
git clone https://github.com/gati3478/dotfiles-public ~/dotfiles-public
cd ~/dotfiles-public && ./bin/bootstrap
```

`bootstrap` asks for your name and email, writes them to `~/.gitconfig.local`,
rewrites the one path kitty's config language cannot template, then symlinks
the rest into place. Existing plain files are backed up before being replaced by
a symlink; the **copied** editor configs (Sublime) are overwritten directly —
back those up yourself if you have already customised them.

## Verifying it afterwards

`manifest.tsv` is the table that drives everything: source file, live path, and
whether the row is a symlink or a copy. `bin/dot-apply` and `bin/dot-doctor` are
shipped alongside it, so the same command that installs this setup can also tell
you whether it is still intact:

```bash
./bin/dot-doctor
```

There is no second list of files anywhere, which is the point — "installed" and
"checked" read the same row.

## Themes

Gruvbox Dark Hard in the terminal, Gruvbox Light in editors — the same family
from opposite poles, deliberately not unified into one scheme. Dark where code
runs, light where it is read; the typeface is shared throughout.
(The reasoning lives in the private source repo's wiki, which is not part of
this mirror.)

MIT.
