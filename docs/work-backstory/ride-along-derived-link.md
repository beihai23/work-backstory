---
arc: ride-along-derived-link
started: daeab5db380d39f4c0673796529bf8371141c5e5
status: resolved
---

# 让 backstory 跟随代码提交，消灭"每次提交后补一次文档提交"

## Intent
用户反馈：插件在目标仓库工作时，每次正常代码提交后都会跟一个纯文档提交，很烦。初始假设是 SKILL.md 措辞问题——"a docs-only commit landing the entry is fine" 等于官方允许补提交，以为改措辞就够。

## Process
- 勘探结论：整个插件没有任何脚本执行 `git commit`，两个 hook 只做 rev-parse 和追加 checkpoint——额外提交完全是模型遵从 SKILL.md 措辞的行为。
- 用户指出真正根因：frontmatter 的 `commits: []`（"SHAs as they land"）。commit 装不下自己的 SHA，每次提交后想记新 SHA 就要再改文档 → 工作区又脏 → 又要一次提交，无限循环；字段在结构上自我挫败。
- 备选方案否决记录：
  - 每个 arc 收尾一次 docs 提交：代码 diff 干净，但 arc 期间文档长期 dirty 有丢失风险，每 arc 仍多一次提交；
  - 文档完全不进仓库（gitignore / 仓库外存储）：零提交，但推翻插件核心设计（in-repo、双向链接、随仓库分享），clone 即丢。
- 定案 ride-along：代码提交时把 entry stage 进**同一个** commit；唯一允许 docs-only 提交的场景是"arc 收尾且无代码可搭车"（纯决策 / 否决类，恰是 SKILL.md 认为最有价值的条目）。
- 鸡生蛋解法：收尾时**先** finalize（status: resolved）**再**打最后一个代码提交，trailer 闭环；entry→commits 方向改为派生（`git log --grep='Backstory:'`），git 原生索引、零维护、抗 rebase/squash。
- 用户追问正文是否该记 commit：不该——git log 就是变更足迹的权威记录，正文独有价值是思考足迹，重合部分最无价值。据此新增纪律"commit 不是捕获触发器"；修订记录为"新决策 + 为何推翻旧的"（语义上是一次 rejection），不是"又改了一版"。
- 端到端验证遇到假失败：`claude -p`（print/SDK 模式）不注入插件 UserPromptSubmit hook，reminder 消失导致 skill 未被选中；prompt 显式指定使用 skill 后全部断言通过。

## Decisions
- 双向链接改为**非对称**：commit→entry 方向用 trailer（存储的，git 原生、跟 message 走、rebase/squash 后仍存活）；entry→commits 方向用 grep 派生（不存 SHA）。理由：自指悖论之外，SHA 恰恰在 rebase/squash 流程里最易失效，备份方向存了最不耐久的数据。
- `started` 保留（write-once，锚定"之前"的快照，供 `git diff started..`）；`commits` / `end` 字段删除，grep recipe 内嵌进 entry 模板使文档自描述。
- ride-along 为默认路径；docs-only 提交仅限无代码收尾；用户在会话外手动 commit 不触发任何补救动作，entry 留脏搭下一次。
- Process 锚点只用语义锚（"改用 pub/sub 之后"），禁止 SHA；Related 只记 PR 号等无自指问题的稳定标识。

## Lessons
- 维护一份与既有索引冗余的清单，清单自己会变成持续制造脏工作区的永动机——设计字段前先问"git（或某个既有系统）是否已经索引了这个信息"。
- `claude -p` 不跑 user-turn hooks：用它验证 skill 行为时必须在 prompt 里显式调用 skill，否则得到的是假失败而非 bug。
- 本机插件生效路径 = 源码仓库 → `~/.claude/skills/work-backstory`（standalone）+ 插件缓存目录，两处都要同步；marketplace 的正规版本化更新需先 push 到 GitHub。

## Related
- 本 arc 的提交集可派生：`git log --grep='Backstory: docs/work-backstory/ride-along-derived-link.md'`
- evals/evals.json case 6（ride-along-single-commit）即本次行为的回归用例
