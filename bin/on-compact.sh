#!/usr/bin/env bash
# work-backstory · PreCompact hook
#
# IMPORTANT (from the Claude Code hooks reference): the PreCompact event can only
# BLOCK or ALLOW compaction — it CANNOT inject Claude-readable context. So a hook
# cannot make Claude "flush right before compaction"; by the time compaction
# fires, capture had to already happen during the turn (the skill's continuous
# capture). The anti-loss guarantee is that continuous capture, not this hook.
#
# What this hook CAN do safely (no block, so auto-compaction is never disrupted):
# leave a one-line provenance checkpoint in the active entry's Process section,
# marking where the conversation was compacted. No-op outside a repo or when no
# active (non-resolved) entry exists. Always exits 0.
set -uo pipefail

INPUT="$(cat)"
TRIGGER="$(printf '%s' "$INPUT" | grep -oE '"trigger"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -oE '"[^"]*"$' | tr -d '"')"
[ -z "$TRIGGER" ] && TRIGGER="unknown"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$ROOT" ] && exit 0

BD="$ROOT/docs/work-backstory"
[ -d "$BD" ] || exit 0

# active = first entry whose status is not "resolved"
ACTIVE=""
shopt -s nullglob
for f in "$BD"/*.md; do
  grep -q '^status: *resolved' "$f" || { ACTIVE="$f"; break; }
done
[ -z "$ACTIVE" ] && exit 0

# best-effort checkpoint append; never block
printf '\n- _[context compacted (%s) — pre-compaction detail is summarized in the session transcript]_\n' "$TRIGGER" >> "$ACTIVE"
exit 0
