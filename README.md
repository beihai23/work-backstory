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

Entries live in-repo at `docs/work-backstory/<slug>.md` and are **bidirectionally linked** to git. The link is deliberately asymmetric: commits on a tracked arc carry a `Backstory:` pointer in their message (stored — git-native, rebase-safe), while the arc's commits are recovered on demand via `git log --grep='Backstory:'` (derived — an entry can't contain the hash of the commit that carries it). The entry also **rides along**: when Claude commits code on a tracked arc, the current entry is staged into the *same* commit, so one commit carries the change and its thinking together. No separate docs-only follow-up commits mid-arc; the only docs-only commit is an arc that resolves with no code at all (design-only, or *"we decided not to do X"* — often the most valuable entry of all).

### Entry structure

````markdown
---
arc: <slug>
started: <HEAD sha when the arc began>
status: draft   # draft | active | resolved
---

## Intent      ← the departure: what problem, why now, and the initial expectation (应然)
## Process     ← living log; append in-the-moment, flush before compaction
## Decisions   ← distilled from Process
## Lessons     ← distilled from Process; forward-useful gotchas
## Related     ← PRs, sibling arcs, files; this arc's commits: git log --grep='Backstory:'
````

### Writing discipline (anti-表功)

The enemy isn't specific words — it's **thinness**. A line full of real decisions, numbers, and reasoning is valuable even if it uses an adjective; a correct-but-generic line ("improved the auth flow") is worthless without them. Write dense, specific, decision-oriented content. Default language is **Chinese (中文)**; switch to English only when there's a real reason, and then for the whole entry.

## Install

```bash
git clone https://github.com/beihai23/work-backstory ~/.claude/skills/work-backstory
```

Then restart Claude Code. For a publishable install, register this repo as a marketplace and install the plugin:

```bash
/plugin marketplace add https://github.com/beihai23/work-backstory
/plugin install work-backstory@work-backstory-marketplace
```

If you only want the standalone skill, installing the repo under `~/.claude/skills/work-backstory` makes the skill available. The marketplace/plugin path is what loads the companion hooks from `.claude-plugin/plugin.json` and `hooks/hooks.json`, which is what nudges Claude at the start of each turn to invoke `work-backstory` for substantive repo work. To consult past entries, just ask *"这段代码的来龙去脉?"*

## Status

v0.4. The behavior-guidance was validated in iteration-1 evals: with the skill, Claude creates a durable `docs/work-backstory/` entry where baseline produces only ephemeral notes — and an entry was captured with **zero commits** in the repo. v0.4 adds a companion **Claude Code plugin hook** because skill registration alone only makes `work-backstory` available; Claude still has to choose the `Skill` tool during conversation. The plugin's `UserPromptSubmit` hook injects a short reminder inside git repos to use the skill for substantive work and skip trivial/status-only turns. The repository now ships a `.claude-plugin/marketplace.json` so it can be added and installed as a marketplace-backed plugin.

A **`PreCompact` hook is also wired**: it appends a one-line compaction checkpoint to the active entry's Process — provenance for where the conversation was summarized. Per the Claude Code hooks reference, `PreCompact` can only block/allow compaction — it **can't** inject context to trigger a pre-compaction flush — so the real anti-loss guarantee is still the skill's continuous capture, reinforced by the prompt-submit reminder. See `evals/` for the test cases.

**v0.5 — ride-along commits and a derived reverse link.** The entry rides inside the arc's own code commits: `git add` the entry together with the code, one commit carries both, and its `Backstory:` trailer is self-consistent. Separate docs-only follow-up commits mid-arc are an explicit anti-pattern; the only docs-only commit is a resolved arc that produced no code. The old `commits:` frontmatter list is gone — a commit can't contain its own SHA, and maintaining that list is what caused the follow-up-commit churn — so the entry→commits direction is now derived via `git log --grep='Backstory:'`, with the recipe embedded in the entry template.

## License

MIT
