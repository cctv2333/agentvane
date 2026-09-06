# AgentVane 参考手册（按需读，不自动注入）

> 本文件是 `AGENTS.md` / `agentvane.md` 引用的**详细排障与上下文管理细则**。
> 用途：**只在真正需要时读**（改代码、跑脚本、查某一类坑），**不要整读、不要每轮注入**。
> 这样能避免"文件越积越多 → 上下文越来越大 → 读不完"。核心强制规则放 `AGENTS.md`（自动注入、一页内），细节在本文件。

---

## 一、上下文与文件体积管理（重要：别让台账/技能把上下文撑爆）

> **原则：能不全读就不全读；只读"索引 + 最近 + 相关"；长尾归档到按需文件。**
> 项目的 `WORKLOG.md` / `BUG_LEDGER.md`（会持续增长）**绝不允许整读**。

1. **分层读取**：开工只读台账**顶部索引**（任务标题 + #号 + 日期列表）+ **最近 N 条（≤10 条）** + **当前任务相关条目**。**绝不整读整个文件。**
2. **定位历史**：查历史同类用 **grep/搜索**（按 #号、功能名、Bug 现象关键词），命中后**只读该条目块**，不整读。
3. **滚动归档**：主文件只保留**最近 N 条**（建议 30–50 条）；更早条目**按月归档**到 `WORKLOG-archive-YYYYMM.md` / `BUG_LEDGER-archive-YYYYMM.md`，主文件顶部留**索引**（条目标题 + 归档去向）。归档文件只在需要旧记录时按需读。
4. **条目精简**：每条台账 3–6 行，只写"现象/根因/防御"，**禁止**把大段代码、日志、完整输出整段 dump 进台账。
5. **自动注入面要小**：`AGENTS.md`（每轮自动注入）只放**核心强制规则**（一页内）；细节、长命令放**本参考文件**，**按需读、不自动注入**。
6. **技能按需加载**：DSH 的 `agentvane`、流程文档属"用到才读"。开工只让 AI 加载核心，长篇细节靠引用文件。

---

## 二、PowerShell 中文编码 / 输出乱码（Windows PowerShell 5.1，chcp 936/GBK）

> 已验证事实：PS 5.1 的 `Get-Content` **默认按系统 ANSI(GBK)** 读"无 BOM 的 UTF-8"文件 → 中文乱码；`Out-File/Set-Content -Encoding UTF8` 写的是**带 BOM** 的 UTF-8。

- **读 UTF-8 不乱码**：`Get-Content -LiteralPath $p -Encoding UTF8`，或最稳 `[System.IO.File]::ReadAllText($p,[System.Text.Encoding]::UTF8)`。
- **写带 BOM 的 UTF-8**（给 PS/记事本，适合 `.ps1`/config.json）：`$c | Out-File -LiteralPath $p -Encoding UTF8`（5.1 下 = 带 BOM）。
- **写不带 BOM 的 UTF-8**（给 Node/git/go）：`[System.IO.File]::WriteAllText($p,$c,(New-Object System.Text.UTF8Encoding($false)))`。
- **控制台中文不乱码**（读 git/node/go 输出前先设）：
  ```powershell
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8   # 读方向：解码原生程序 stdout
  $OutputEncoding          = [System.Text.Encoding]::UTF8   # 写方向：发给原生程序 stdin
  chcp 65001 > $null
  ```
  **别搞反**：`[Console]::OutputEncoding` 管"读"，`$OutputEncoding` 管"发"。
- **诊断 JSON 损坏**：别用 `Get-Content`（默认 GBK 误报），用 `[IO.File]::ReadAllText(...,[Text.Encoding]::UTF8)`。
- **cmd/.bat 相反**：按 ANSI 解码 → 中文必须纯 ASCII，换行必须 CRLF。
- **BOM 会累积**：加 BOM 前先剥旧 BOM。
- **中文文件名**：命令行内联传中文路径易被 GBK 破坏 → 写进 Node 脚本内部处理。
- **here-string `@'...'@` 偶发静默无输出** → 写 `.ps1`（UTF-8 带 BOM）再 `-File` 执行。
- **`-or`/`-and` 返回布尔**不是短路取值：`($x -or '')` 是 `$True`，要 `if($x){$x}else{''}`。
- **EAP=Stop + stderr**：`2>&1` 让 stderr 变 ErrorRecord，Stop 下抛；用 `2>$null` 或临时降 EAP。

---

## 三、Node 脚本编写

- 生成 JS 源码时，换行转义写 `\\n`（多一层）。
- 相对路径落在启动目录，写项目文件用绝对路径或 `path.resolve(__dirname,...)`。
- 改 CRLF 文件替换串换行必须 `\r\n`。
- JSON：`JSON.parse`→改→`JSON.stringify` 写回→**立刻再 `JSON.parse` 验证**。
- Windows 沙箱 `stdio:'pipe'` 捕获输出可能 EPERM → `stdio:'inherit'` 或 `execSync`+写文件绕开。

---

## 四、其它常见坑

- 改了"没生效" → 核对产物/进程版本 + 数据目录；语言包磁盘优先，改语言包必递增版本号。
- 工具/截图故障**禁止死磕**：终止→记台账→查资料→有边界修（2 次定位，失败即停）。
- PowerShell 多行/命令链：不支持 heredoc/`&&`；多行 body 写文件再 `git commit -F`，提交后 `git log --oneline -2`+`git status --short` 验证。
- 构建循环依赖 → 手动补生成文件打破；打包/构建命令**禁用 `-clean` 类清理**（会清空产物目录）。
- 引擎默认参数是防膨胀安全值，接入配置时必须跟随。

---

*按需参考，不自动注入；核心强制规则见仓库根 `AGENTS.md`。*
