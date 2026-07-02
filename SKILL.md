---
name: work-backstory
version: 0.3.0
description: |
  Capture *how the codebase actually evolves* — the why, the decisions, the
  rejected approaches, the gotchas — into a durable in-repo backstory, written *as
  the work happens* (during the conversation), not deferred to commit time. One
  entry per problem-solving arc (which may span sessions, branches, and commits —
  or none at all), bidirectionally linked to git commits. The goal is forward
  reference for the next reader, not a record of accomplishment. Use this
  whenever engaging a substantive problem or change — at the start of work, as
  valuable decisions/surprises/rejections occur mid-conversation, before context
  gets compacted, when committing, and when an arc resolves — even if the user
  never names it. Also proactively consult it when the user asks "why did we build
  X this way", "what's the backstory here", or — in Chinese — "这段代码的来龙去脉",
  or wants context before changing code in a tracked area. (gstack-style)
hooks:
  PreCompact:
    - hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/on-compact.sh"
---

# work-backstory — the 来龙去脉 of how the codebase evolves

*work-backstory is the **来龙去脉** of a change: 来龙 (where it started — the Intent,
the problem, the why) and 去脉 (where it went — the decisions, the dead ends, the
lessons). The commit log shows the diff; this captures the thinking behind it, so
the next reader can trace a change in both directions — back to why it began,
forward through how it unfolded.*

## What this is for

The commit log records **what** changed. It almost never captures **why** a
change exists, what problem it solved, what was tried and rejected, or what was
learned. That thinking lives in the conversation — and it's the first thing to
go. By commit time the reasoning has already faded from working memory, and
months later, when someone asks *"why is this like this?"*, there's nothing to
point to.

work-backstory captures that thinking **as it happens**, into a durable in-repo
document, so the evolution of the codebase — the decisions, the dead ends, the
surprises — survives. It is written for the **next reader** (your future self, or
whoever inherits the code), to help a future decision. Not as a record of
accomplishment.

## The unit: a problem-solving arc, not a branch

Every time someone engages Claude with a real problem, an **arc** begins — a
coherent piece of problem-solving. An arc:

- **starts** when a problem or intent is brought to Claude (not at
  `git checkout -b`),
- **spans** however many sessions, branches, and commits it takes — or none at
  all (pure exploration, or a decision not to act),
- **ends** when the problem is resolved: the work landed, OR a decision was
  reached (including *"we're not doing this"* — often the most valuable entry of
  all), OR the thread was explicitly abandoned.

git events are checkpoints **inside** an arc, not its boundaries. Commits are
evidence; they don't define the arc.

## Why capture must happen during the conversation

Process lives in the conversation; git is downstream of it. If you only write
the backstory at commit or merge time, the process is already gone — you'll
reconstruct a thin summary from fading memory and lose exactly the valuable
parts: the rejected approaches, the surprises, the reasoning.

So the entry is a **living document, appended to as the arc unfolds**. Capture
happens in the moment, while the reasoning is fresh. Commits become a moment to
consolidate and link — not the moment to capture.

## The anti-loss guarantee

Three capture moments, none of which depend on git:

1. **Arc start** — when a substantive problem is engaged, stub the entry with the
   Intent (the departure: what problem, why now).
2. **As valuable things happen** — append to the entry's Process log the moment a
   decision is made, an approach is tried and rejected, a surprise or gotcha
   surfaces, or a constraint emerges. Do not wait for a commit. (What counts as
   "valuable" is defined below.)
3. **Before context is compacted** — when the conversation is about to be
   summarized or compacted, flush the still-unrecorded valuable process into the
   entry first. Compaction is precisely when detail gets dropped; flushing
   beforehand is the hard safety net that guarantees nothing valuable is lost —
   across multi-hour, multi-compaction sessions, even if step 2 was imperfect.

If the whole arc never produces a commit, the entry still exists in the working
tree, holding the process. That is the point.

## What's "valuable enough" to record (the density rule)

Record something when a future reader would otherwise hit the same wall or need
the same reasoning. Concretely, capture:

- a **decision** with a non-obvious rationale (chose X over Y, and why),
- an **approach tried and rejected** (what was attempted, and why it didn't work),
- a **surprise or gotcha** (something behaved unexpectedly; the thing that cost
  real time),
- a **constraint or requirement** that surfaced (and where it came from).

Do **not** record routine progress ("edited auth.py", "tests pass") — that is
what the commit log is for. The test for each line: *would this save a future
person time, or prevent a repeated mistake?* If not, skip it.

This is also the anti-表功 rule, properly understood. The enemy is not specific
words like "robust" or "elegant" — it is **thinness**. A line full of real
decisions, real numbers, and real reasoning is valuable even if it happens to use
an adjective; a line that is correct but generic ("improved the auth flow") is
worthless even without them. Write dense, specific, decision-oriented content.
If a line would not help a future decision, cut it. The same standard applies to
**commit messages**: the `Backstory:` pointer should sit on a message that is
itself substantive, not a bare `update`.

## The entry

Stored at `docs/work-backstory/<slug>.md`, committed in-repo. One file per arc;
the slug comes from the feature or problem.

**Language: write the entry's content in Chinese (中文) by default** — the Intent,
Process, Decisions, and Lessons prose. The user works in Chinese, and a backstory
that won't get re-read is pointless, so it should read naturally to them. Keep the
frontmatter keys (`arc`, `started`, `status`, `commits`) and the section headers as
structural labels. Only switch to English when there's a real reason (an
English-only repo, or an entry meant for a wider team) — and then write the *whole*
entry in that language, not a mix.

Structure:

```markdown
---
arc: <slug>
started: <HEAD sha when the arc began — the "before" snapshot>
status: draft   # draft | active | resolved
commits: []     # SHAs as they land — checkpoints inside the arc
---

# <imperative title — what this arc is about>

## Intent
<the departure: what problem brought us here, and why now. A future reader
should grasp this before reading any code.>

## Process   ← the living log; append in-the-moment, flush before compaction
- <decision / rejection / surprise / constraint — one bullet per valuable thing,
  with its reasoning. Anchor loosely to where in the arc it happened.>

## Decisions   ← distilled from Process; the choices that shaped the outcome
## Lessons     ← distilled from Process; forward-useful gotchas & insights
## Related     ← key commits, PRs, sibling arcs, relevant files/modules>
```

Process is the substrate that guarantees completeness; Decisions and Lessons are
the curated distillation drawn from it, refined especially at resolution.
Because they are distilled from a complete Process log rather than reconstructed
from memory, they end up substantive instead of thin.

## The double link

The connection between commits and the entry runs **both ways**, so you can
arrive from either direction and find the other half:

- **Commit message → entry:** every commit on a tracked arc carries
  `Backstory: docs/work-backstory/<slug>.md` in its message.
- **Entry → commits:** the entry records `started` (the merge-base / state before
  the change) and `end` (the merge or squash commit).

Why bidirectional? Reading a commit, you can jump to the *why*. Reading a
backstory, you can jump to the exact diff. One-directional links always leave you
stranded on one side.

## Resuming an arc across sessions

An arc can span sessions. On engaging a problem, check `docs/work-backstory/` for
an active (non-resolved) entry that matches — the current branch is the strongest
hint; the Intent and Related fields disambiguate. If a match exists, resume it
(append to its Process). If not, start a new arc. When ambiguous, prefer
resuming the most recent active entry over spawning a duplicate.

## When the arc resolves

Finalize: distill Process into Decisions and Lessons, set `status: resolved`,
record the final commits, and ensure the entry is committed — even if the arc
produced no code (a docs-only commit landing the entry is fine, and *"we decided
not to do X, here's why"* entries are often the most valuable to preserve). If
the session ends mid-arc, flush Process so it survives and leave `status: active`
for resumption — do not force a resolution.

## Only inside a repo

If the working directory is not inside a git repo, do nothing. (The user's
top-level workspace is a parent of many repos; the skill stays quiet there.) If
`docs/work-backstory/` does not exist, create it on first use. Forward-only: do
not backfill arcs from before the skill existed.

## Consulting it (forward reference)

- **Starting work** on a branch or area: surface the matching entry's Intent and
  Decisions first.
- **"Why is X like this?" / "what was the thinking behind…" / "这段代码的来龙去脉"**:
  search `docs/work-backstory/` for the area or feature and read Intent +
  Decisions + Lessons before answering or changing code.
- **Before a non-trivial change**: check for a related entry — its Decisions and
  Lessons may change your approach.

## Reliability layer (hooks)

The behavior above is the primary mechanism — it works whenever this skill is
active, and iteration-1 showed it captures well. Hooks are a backstop, and a hook
can only do what the Claude Code hooks API allows.

**One hard limit, learned from the hooks reference:** the `PreCompact` event can
only *block or allow* compaction — it **cannot inject Claude-readable context**.
So a hook cannot make Claude "flush right before compaction"; by the time
compaction fires, capture had to already happen during the turn. This is exactly
why the anti-loss guarantee is the skill's *continuous* capture (moments 1–2
above), not a pre-compaction scramble — and that continuous capture is what the
evals validate.

What is wired (in this skill's frontmatter, so it travels with the skill and is
active whenever the skill is):

- **PreCompact** — when an active (non-resolved) entry exists, append a one-line
  *compaction checkpoint* to its Process section (e.g. *_[context compacted
  (auto)]_*). This is provenance: a future reader sees where the conversation was
  summarized. It does **not** block, so auto-compaction is never disrupted, and it
  no-ops outside a repo or when no arc is active.

If future testing shows Claude missing captures mid-arc, the stronger
reinforcement is a `UserPromptSubmit` hook that reminds Claude at the start of
each turn to keep the active entry's Process current — non-blocking, once per
turn. Not wired yet; add it targeted if needed.

The commit-message side of the double link is handled by the skill's behavior
(add the `Backstory: docs/work-backstory/<slug>.md` line to commit messages on a
tracked arc). A native `prepare-commit-msg` git hook can be layered later if
testing shows the pointer going missing.
