# IntelliJ IDEA

Primary IDE. A curated subset of its config **is** tracked in this repo as of
08-08-2026 — in `private/`, because two of IDEA's option files carry an
employer name. This page is the public-facing summary.

IDEA rewrites its XML config continuously and **Settings Sync is enabled**, so
the tracked files are `copy` mode rather than symlinks: a symlink would be
replaced by a regular file the first time sync ran. Settings Sync owns the live
IDE; the repo owns a reviewed, diffable history. `dot-pull` captures
live → repo, `dot-apply` restores repo → live — with IDEA **closed**, since it
rewrites its options on exit.

| Setting           | Value                                                         | Where                                                |
| ----------------- | ------------------------------------------------------------- | ---------------------------------------------------- |
| Actions on Save   | reformat code, **changed lines only**, no import optimisation | Settings → Tools → Actions on Save                   |
| Inline blame      | on                                                            | Settings → Version Control → Git → Show inline blame |
| Keymap            | **stock macOS, zero customisations**                          | Zed mirrors it via `base_keymap: "JetBrains"`        |
| Theme             | **Gruvbox Material Light Island** (third-party plugin)       | reasoning is in the private source repo's wiki, not in this mirror                            |
| Editor font       | Fira Code 16 + ligatures, JetBrains Mono fallback             | matches kitty and Zed                                |
| Method separators | on                                                            | Settings → Editor → General → Appearance             |
| Heap              | `-Xmx6144m`                                                   | `idea.vmoptions` — recorded in the private source repo, not in this mirror            |

> [!warning] Corrected 08-08-2026
> This page previously claimed the keymap was a "macOS **copy** (near-stock)"
> and the theme was "Islands Light". Both were wrong. There are **no** custom
> keymaps — the live `keymaps/` directory is empty and the "macOS copy" that
> older notes describe is a `DELETED` tombstone in the Settings Sync history.
> The theme is a third-party Gruvbox Material plugin, not a bundled JetBrains
> Islands theme; the similar name is what caused the confusion.

New-project defaults live in `…/options/project.default.xml` as
`FormatOnSaveOptions` (`myRunOnSave`, `myAllFileTypesSelected`,
`myFormatOnlyChangedLines`). Existing projects need the toggle set once each.

## The caret

IDEA offers **block or vertical bar only**. There is no underline caret outside
IdeaVim's modal editing —
[IJPL-28715](https://youtrack.jetbrains.com/issue/IJPL-28715) has been open
since 2014 and never left `State: Submitted`. The IDE **terminal** does support
it and is set to `UNDERLINE`, matching kitty and Zed; the IDEA editor is the one
surface in this setup where the underscore caret is not possible.

## Housekeeping

After a major-version migration, purge the previous version's config, cache and
log directories across `Application Support`, `Caches` and `Logs` — the 2026.1
purge freed ~14 GB.

The AI code-embeddings index under `JetBrains/analyzer/` grows without bound
(6.5 GB across two trees by 08-08-2026) and is fully regenerable. It rebuilds
whenever AI features re-index, so purging it is a recurring chore rather than a
one-time fix.
