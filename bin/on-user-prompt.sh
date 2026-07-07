#!/usr/bin/env bash
# work-backstory · UserPromptSubmit hook
#
# Skill visibility is not the same as skill use. Claude Code lists available
# skills, but the model still has to choose the Skill tool before SKILL.md is
# loaded. This hook adds a small, Claude-readable reminder at the start of each
# turn inside a git repo so substantive work routes through work-backstory.
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$ROOT" ] && exit 0

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"<work-backstory-reminder>\nIf this turn starts or continues substantive work in this git repo, invoke the work-backstory Skill before acting. Keep docs/work-backstory/<slug>.md current with decisions, rejected approaches, surprises, and constraints as they happen; skip trivial lookups, pure status checks, and non-repo work.\n</work-backstory-reminder>"}}
JSON
