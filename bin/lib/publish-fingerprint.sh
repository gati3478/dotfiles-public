# publish_fingerprint: hash of everything dot-publish actually ships.
#
# dot-doctor's currency check used to hash only `HEAD:public`, but
# dot-publish also stages LICENSE, docs/public-README.md, bin/dot-apply,
# bin/dot-doctor, and manifest.tsv (the source manifest.tsv drives the
# generated, public-only one dot-publish writes into the mirror). A change
# to any of those changes what ships without touching public/ at all, so
# hashing HEAD:public alone can say "current" while the mirror is stale.
# Single-sourced so the writer (dot-publish) and the reader (dot-doctor)
# cannot drift apart on which files count — the exact failure class the
# manifest.tsv split exists to prevent, one layer further in.
#
# Usage: publish_fingerprint <repo-path>
publish_fingerprint() {
  local repo="$1"
  {
    git -C "$repo" rev-parse HEAD:public              2>/dev/null || echo none
    git -C "$repo" rev-parse HEAD:LICENSE              2>/dev/null || echo none
    git -C "$repo" rev-parse HEAD:docs/public-README.md 2>/dev/null || echo none
    git -C "$repo" rev-parse HEAD:bin/dot-apply        2>/dev/null || echo none
    git -C "$repo" rev-parse HEAD:bin/dot-doctor       2>/dev/null || echo none
    git -C "$repo" rev-parse HEAD:manifest.tsv         2>/dev/null || echo none
    # This file is itself staged into the mirror (dot-publish, the bin/lib copy).
    # Omitting it meant editing this very function changed what the mirror ships
    # while leaving the fingerprint identical — so dot-doctor reported "public
    # mirror is current" against a mirror that was not. Found 14-08-2026. The
    # self-reference is safe: this hashes the file's git blob, not its output.
    git -C "$repo" rev-parse HEAD:bin/lib/publish-fingerprint.sh 2>/dev/null || echo none
  } | shasum -a 256 | awk '{print $1}'
}
