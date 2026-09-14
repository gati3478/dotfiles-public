#!/bin/sh
# Stdio wrapper for the Context7 MCP server.
# Reads the API key from Keychain at run time and passes it via env var,
# so the secret stays out of ~/.claude.json (which Claude Code does not
# expand ${VAR} references in). Called by Claude Code's mcpServers entry
# as the `command`.
set -u
USER_NAME="$(id -un)"
CONTEXT7_API_KEY="$(/usr/bin/security find-generic-password -s mcp-context7 -a "$USER_NAME" -w 2>/dev/null)"
export CONTEXT7_API_KEY
# Claude Code launches this with a minimal PATH, so npx is resolved here
# rather than assumed. The absolute path was /opt/homebrew/bin/npx until
# 14-09-2026, which is Apple-Silicon Homebrew only — dead on an Intel Mac
# (/usr/local) and on any node that is not Homebrew's.
NPX="$(command -v npx 2>/dev/null || true)"
for candidate in /opt/homebrew/bin/npx /usr/local/bin/npx; do
  [ -n "$NPX" ] || { [ -x "$candidate" ] && NPX="$candidate"; }
done
[ -n "$NPX" ] || { echo "mcp-context7: npx not found — install node, or put npx on PATH" >&2; exit 1; }
exec "$NPX" -y @upstash/context7-mcp
