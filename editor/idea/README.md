# IntelliJ IDEA

IDEA rewrites its XML config continuously, so it is documented here rather
than tracked. Settings Sync is enabled and carries plugins and keymaps.

| Setting         | Value                                                         | Where                                                |
| --------------- | ------------------------------------------------------------- | ---------------------------------------------------- |
| Actions on Save | reformat code, **changed lines only**, no import optimisation | Settings → Tools → Actions on Save                   |
| Inline blame    | on                                                            | Settings → Version Control → Git → Show inline blame |
| Keymap          | macOS copy (near-stock)                                       | Zed mirrors this via `base_keymap: "JetBrains"`      |
| Theme           | Islands Light + plain Light scheme                            | see `docs/preferences.md`                            |

New-project defaults live in `…/JetBrains/IntelliJIdea<version>/options/project.default.xml`
as `FormatOnSaveOptions` (`myRunOnSave`, `myAllFileTypesSelected`,
`myFormatOnlyChangedLines`). Existing projects need the toggle set once each.

After a major-version migration, purge the previous version's config, cache
and log directories across `Application Support`, `Caches` and `Logs` —
the 2026.1 purge freed ~14 GB.
