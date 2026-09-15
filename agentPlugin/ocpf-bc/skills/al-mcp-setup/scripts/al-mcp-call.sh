#!/bin/sh
# OCPF one-shot AL MCP Server call for macOS and Linux (from the ocpf-bc plugin's al-mcp-setup skill).
#
# Runs one AL MCP Server tool and exits. For sessions that can't see the `al` server yet: Claude
# Code and Copilot CLI load MCP servers only when a session starts, so a server registered
# mid-session isn't available until the next one. Nothing is installed; this starts the same
# server through al-mcp.sh beside this file.
#
#   sh scripts/al-mcp-call.sh <project folder> <tool name> ['<JSON arguments>'] [timeout seconds]
#   sh scripts/al-mcp-call.sh . al_downloadsymbols '{"globalSourcesOnly":true}'
#   sh scripts/al-mcp-call.sh . al_compile '{"options":{"onlyErrors":true}}'
#
# Prints the tool's JSON-RPC response on stdout. Exits 0 when the response arrives, 1 otherwise.

set -u

[ $# -ge 2 ] || { echo "usage: al-mcp-call.sh <project folder> <tool name> ['<JSON arguments>'] [timeout seconds]" >&2; exit 2; }
project="$(cd "$1" 2>/dev/null && pwd)" || { echo "OCPF AL MCP call: project folder not found: $1" >&2; exit 2; }
tool="$2"
arguments="${3:-}"
[ -n "$arguments" ] || arguments='{}'
timeout="${4:-900}"
here="$(cd "$(dirname "$0")" && pwd)"

work="$(mktemp -d "${TMPDIR:-/tmp}/ocpf-al-mcp.XXXXXX")" || exit 1
mkfifo "$work/in" || { rm -rf "$work"; exit 1; }
: > "$work/out"

# The project path is passed at launch, so it's loaded before any request arrives.
sh "$here/al-mcp.sh" "$project" < "$work/in" > "$work/out" 2> "$work/err" &
server=$!
exec 3> "$work/in"

cleanup() {
  exec 3>&- 2>/dev/null
  kill "$server" 2>/dev/null
  wait "$server" 2>/dev/null
  rm -rf "$work"
}

# Waits for the response with the given id; prints it and returns 0, or returns 1 on timeout/exit.
await() {
  waited=0
  while [ "$waited" -lt "$2" ]; do
    line="$(grep -m 1 "\"id\":$1[,}]" "$work/out")"
    if [ -n "$line" ]; then
      printf '%s\n' "$line"
      return 0
    fi
    if ! kill -0 "$server" 2>/dev/null; then
      cat "$work/err" >&2
      return 1
    fi
    sleep 1
    waited=$((waited + 1))
  done
  echo "OCPF AL MCP call: no response from $tool within $2 seconds." >&2
  return 1
}

printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"ocpf-al-mcp-call","version":"1.0.0"}}}' >&3
if ! await 1 120 > /dev/null; then
  cleanup
  exit 1
fi
printf '%s\n' '{"jsonrpc":"2.0","method":"notifications/initialized"}' >&3
printf '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"%s","arguments":%s}}\n' "$tool" "$arguments" >&3

await 2 "$timeout"
status=$?
cleanup
exit "$status"
