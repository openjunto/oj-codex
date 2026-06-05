#!/usr/bin/env bash
# bootstrap.sh — install oj-codex components Codex does not auto-discover from a plugin.
#
#   1) native subagent definitions  .codex/agents/*.toml -> $CODEX_HOME/agents/
#   2) lifecycle hooks              hooks/hooks.json      -> $CODEX_HOME/hooks.json (merged)
#
# Codex discovers agents only from ~/.codex/agents (or <repo>/.codex/agents), and
# plugin-bundled hooks are not yet reliably loaded by the runtime — so we install both
# into $CODEX_HOME directly. Re-running replaces oj-* agents and de-dups hook entries.
set -euo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME/agents"

# 1) agent definitions
n=0
for t in "$PLUGIN_ROOT"/.codex/agents/*.toml; do
  [ -e "$t" ] || continue
  cp -f "$t" "$CODEX_HOME/agents/"; n=$((n+1))
done
echo "oj-codex: installed $n agent definition(s) -> $CODEX_HOME/agents/"

# 2) hooks — merge with the absolute plugin path substituted for ${PLUGIN_ROOT}
if command -v jq >/dev/null 2>&1; then
  dst="$CODEX_HOME/hooks.json"
  [ -f "$dst" ] || echo '{"hooks":{}}' > "$dst"
  tmp="$(mktemp)"
  sed "s#\${PLUGIN_ROOT}#${PLUGIN_ROOT}#g" "$PLUGIN_ROOT/hooks/hooks.json" > "$tmp"
  # Deep-merge SessionStart/SubagentStart arrays, then de-dup by command so re-runs are idempotent.
  jq -s '
    def merge_event($d;$s;$k): ($d[$k] // []) + ($s[$k] // []) | unique_by(.hooks[0].command // tostring);
    .[0] as $d | .[1] as $s
    | $d * {hooks: ($d.hooks + $s.hooks
        + {SessionStart: merge_event($d.hooks;$s.hooks;"SessionStart"),
           SubagentStart: merge_event($d.hooks;$s.hooks;"SubagentStart")})}
  ' "$dst" "$tmp" > "$dst.new" && mv "$dst.new" "$dst"
  rm -f "$tmp"
  echo "oj-codex: merged hooks -> $dst"
else
  echo "oj-codex: jq not found — add $PLUGIN_ROOT/hooks/hooks.json to $CODEX_HOME/hooks.json manually." >&2
fi

echo "oj-codex: done. Restart Codex; run '/hooks' to confirm, and '/agent' to use the experts."
