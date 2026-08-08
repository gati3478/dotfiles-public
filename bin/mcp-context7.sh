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
exec /opt/homebrew/bin/npx -y @upstash/context7-mcp
