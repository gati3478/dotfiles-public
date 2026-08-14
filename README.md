# Osaka Jade

My terminal and editor setup — kitty, zsh, starship, the cship Claude Code
statusline, Zed and Sublime. Generated from a private dotfiles repo, so
what you see here is the whole shareable surface.

## What you get

- **kitty** on the Osaka Jade palette — FiraCode Nerd Font Mono at 16pt with
  ligatures, an underline caret, copy-on-select, 50k scrollback paged through `bat`
- **zsh** — history that searches by real prefix, mise-managed runtimes,
  fzf + zoxide + eza, autosuggestions and syntax highlighting
- **starship** in Osaka Jade, doubling as line 1 of the statusline
- **cship** — a four-line Claude Code statusline
- **Zed** on Gruvbox Light with JetBrains keybindings

## Install

```bash
git clone https://github.com/gati3478/osaka-jade ~/osaka-jade
cd ~/osaka-jade && ./bin/bootstrap
```

`bootstrap` asks for your name and email, writes them to `~/.gitconfig.local`,
then symlinks the rest into place. Existing plain files are backed up before
being replaced by a symlink; the copied editor configs (Sublime) are
overwritten directly — back those up yourself if you've already customized
them.

## Themes

Osaka Jade in the terminal, Gruvbox Light in editors — deliberately not
unified. Each surface keeps its own character; only the typeface is shared.
(The reasoning lives in the private source repo's wiki, which is not part of
this mirror.)

MIT.
