# work-backstory

> The **来龙去脉** of how your codebase evolves — captured as it happens, not lost at commit time.

`work-backstory` is a [Claude Code](https://claude.com/claude-code) skill that records *why* a change exists, what was decided, what was tried and rejected, and what was learned — the thinking that **never fits in a commit message** and is usually the first thing lost.

In Chinese, **来龙去脉** (láilóng-qùmài) is the whole causal story of how something came to be:

- **来龙** — where it started: the Intent, the problem, the *why*
- **去脉** — where it went: the decisions, the dead ends, the lessons

A commit log shows the diff. `work-backstory` captures the thinking behind it, so the next reader (your future self, or whoever inherits the code) can trace a change in **both directions**.

## The problem it solves

Process lives in the conversation; git is downstream of it. If you only write things down at commit or merge time, the reasoning has already faded — you reconstruct a thin summary and lose exactly the valuable parts: the rejected approaches, the surprises, the rationale.

So `work-backstory` is a **living document, appended to as the work unfolds**, with an explicit anti-loss guarantee.

## How it works

The unit is a **problem-solving arc**, not a branch. An arc begins the moment a real problem is engaged (not at `git checkout -b`), spans as many sessions / branches / commits as it takes — or none at all — and ends when the problem is resolved, including *"we decided not to do this"* (often the most valuable entry of all).

Three capture moments, none of which depend on git:

1. **Arc start** — stub the entry with the Intent (the departure: what problem, why now).
2. **As valuable things happen** — append to the Process log the moment a decision is made, an approach is tried and rejected, a surprise surfaces, or a constraint emerges.
3. **Before context is compacted** — flush still-unrecorded process into the entry *before* the compaction throws it away. This is the hard safety net that guarantees nothing valuable is lost.

Entries live in-repo at `docs/work-backstory/<slug>.md`, committed, and are **bidirectionally linked** to git: commit messages carry a `Backstory:` pointer; the entry records its start/end commits.

### Entry structure

````markdown
---
arc: <slug>
started: <HEAD sha when the arc began>
status: draft   # draft | active | resolved
commits: []     # checkpoints inside the arc
---

## Intent      ← the departure: what problem, why now, and the initial expectation (应然)
## Process     ← living log; append in-the-moment, flush before compaction
## Decisions   ← distilled from Process
## Lessons     ← distilled from Process; forward-useful gotchas
## Related     ← commits, PRs, sibling arcs, files
````

### Writing discipline (anti-表功)

The enemy isn't specific words — it's **thinness**. A line full of real decisions, numbers, and reasoning is valuable even if it uses an adjective; a correct-but-generic line ("improved the auth flow") is worthless without them. Write dense, specific, decision-oriented content. Default language is **Chinese (中文)**; switch to English only when there's a real reason, and then for the whole entry.

## Install

```bash
git clone https://github.com/beihai23/work-backstory ~/.claude/skills/work-backstory
```

Then restart Claude Code. The skill engages on its own — at the start of substantive work, mid-conversation as decisions happen, before context compaction, at commit, and at arc resolution. You don't have to invoke it by name. To consult past entries, just ask *"这段代码的来龙去脉?"*

## Status

v0.3. The behavior-guidance was validated in iteration-1 evals: with the skill, Claude creates a durable `docs/work-backstory/` entry where baseline produces only ephemeral notes — and an entry was captured with **zero commits** in the repo. A **`PreCompact` hook is wired** (in the skill's frontmatter, so it travels with the skill and fires for anyone who installs it): it appends a one-line compaction checkpoint to the active entry's Process — provenance for where the conversation was summarized. Per the Claude Code hooks reference, `PreCompact` can only block/allow compaction — it **can't** inject context to trigger a pre-compaction flush — so the real anti-loss guarantee is the skill's *continuous* capture above, not the hook. A `UserPromptSubmit` reminder or a `PostCompact` summary-persist hook can be added later if testing shows misses. See `evals/` for the test cases.

## License

MIT
