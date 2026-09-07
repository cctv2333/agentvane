# AgentVane

> **让 AI 开发代理稳稳走在"先想清楚、真实验证、如实记录、安全前置"的路径上。**
> A vane stays steady and points true — AgentVane keeps your coding agent on a disciplined path.

AgentVane 是一个**小而独立、可组合**的 AI 开发技能集合（skills collection），不是一个大流程文档。每个技能只做一件事、触发词很窄，需要时才加载，避免上下文膨胀。它把这些年里真实项目反复踩的坑（同一个错误犯很多次、不做真实验证、改一个 bug 引出多个 bug、密钥泄露）固化成可执行的纪律。

---

## 技能列表

| 技能 | 是什么 | 何时触发 |
|---|---|---|
| [`skills/agentvane`](skills/agentvane/SKILL.md) | **实事求是·工程化纪律**：强制内核（4 条思维硬规则 + 第 0 步台账 + 安全红线 + 轻重缓急/主次矛盾 + 实事求是问题回路）+ 按需方法论 | 开始/继续写代码、跑测试构建、准备提交、或遇问题需诊断/查根因/复盘时 |
| [`skills/windows-gotchas`](skills/windows-gotchas/SKILL.md) | **Windows/PowerShell/Node 排障**：中文编码/输出乱码、BOM、幂等命令、Node 换行转义等 | 报"乱码/编码/PowerShell 报错/Node 脚本失败"时 |

> 支持：DeepSeek Harness / Codex / Cursor / Copilot / Chatbox / Claude Code（均按 `SKILL.md` 规范）。

---

## 安装

### 一键链接到 agent 自动发现的目录（推荐，含 Chatbox）
```bash
bash scripts/link-skills.sh
```
它会把这些技能**软链**进 `~/.claude/skills` 和 `~/.agents/skills`（Chatbox 也会自动发现 `~/.agents/skills`）。链到本仓库，所以 `git pull` 即更新。**要卸载就删那些目录里的软链。**

### 用 skills.sh CLI（可挑选、可编辑）
```bash
npx skills@latest add cctv2333/agentvane
```
自动挑你想要的技能装到你的项目/agent。

### 手动复制
把 `skills/agentvane/`、`skills/windows-gotchas/` 整个文件夹复制到 `~/.agents/skills/` 或 `<项目>/.claude/skills/`。
> **注意**：每个技能文件夹包含 `SKILL.md` + 内部参考文件（如 `reference.md`）——**要整目录复制**，别只拿 `SKILL.md`，否则内部引用会悬空。

### Chatbox「从 GitHub 仓库安装 URL」
适用于**仓库根目录直接放 `SKILL.md`** 的仓库。本仓库是**集合**（技能在 `skills/<名>/`），用 URL 方式可能枚举不出来——**建议用上面 `link-skills.sh` 或 `skills.sh`**（把技能放进 `~/.agents/skills`，Chatbox 会自动发现）。

---

## 使用

- 输入框敲 `/agentvane`（或在 Work Mode 里让它按需加载）即启用工作流程纪律。
- `/windows-gotchas` 处理 Windows/编码类报错。
- 想强制走流程：开工时说 **"按 agentvane 流程来，先写台账再动手"**。

---

## 为什么是"集合"而不是一个文档

审计+踩坑得出的结论：**一个大流程文档复制 N 份必然漂移、触发词必然过宽**。所以拆成小技能，各管各的、窄触发、内部带参考文件（随技能复制），并配脚本保持健康：

- `scripts/list-skills.sh` —— 枚举技能。
- `scripts/check-consistency.mjs` —— 校验 frontmatter（name=文件夹名、无 BOM、有 description）+ 关键纪律句不漂移；`--check` 可作门禁。
- `scripts/link-skills.sh` —— 链接到 agent 自动发现目录。
- `scripts/pre-commit.sh` —— **提交门禁**：gitleaks 密钥扫描 + check-consistency + list-skills，任一失败即阻止提交；已挂 `.git/hooks/pre-commit`（`core.hooksPath=.githooks`）。

---

## 维护约定

- 一个技能 = `skills/<name>/SKILL.md`；`name` 小写+连字符且＝文件夹名；frontmatter 仅 `name`+单行 `description`。
- 触发词要窄；通用纪律与项目专属分开（专属加"（若项目为 X）"或放独立窄技能）。
- 改完跑 `node scripts/check-consistency.mjs` + 更新 README 技能清单与 `CONTEXT.md`。
- 注意 UTF-8（见 `skills/windows-gotchas`）。

## 许可

[MIT](LICENSE) · 版权人见 LICENSE。

---

*由真实项目教训提炼；Windows/PowerShell 命令已在 Windows PowerShell 5.1 实测。*
