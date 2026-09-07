---
name: windows-gotchas
description: Windows / PowerShell / Node pitfalls. Use when the user reports garbled Chinese, encoding problems, a PowerShell error, a Node script failing, or asks how to read/write files with Chinese text on Windows.
---

# Windows / PowerShell / Node 坑

只讲排障，**不**是流程纪律（那是 `agentvane`）。本技能在 Windows PowerShell 5.1（chcp 936/GBK）实测。

---

## 一、PowerShell 中文编码 / 输出乱码

> 已核实：PS 5.1 的 `Get-Content` **默认按系统 ANSI(GBK)** 读"无 BOM 的 UTF-8"文件 → 中文乱码；`Out-File/Set-Content -Encoding UTF8` 写的是**带 BOM** 的 UTF-8。

- **读 UTF-8 不乱码**：`Get-Content -LiteralPath $p -Encoding UTF8`，或最稳 `[System.IO.File]::ReadAllText($p,[System.Text.Encoding]::UTF8)`。
- **写带 BOM 的 UTF-8**（给 PS/记事本，适合 `.ps1`/config.json）：`$c | Out-File -LiteralPath $p -Encoding UTF8`（5.1 = 带 BOM）。
- **写不带 BOM 的 UTF-8**（给 Node/git/go）：`[System.IO.File]::WriteAllText($p,$c,(New-Object System.Text.UTF8Encoding($false)))`。
- **控制台中文不乱码**（读原生程序输出前先设）：
  ```powershell
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8   # 读方向：解码原生程序 stdout
  $OutputEncoding          = [System.Text.Encoding]::UTF8   # 写方向：发给原生程序 stdin
  chcp 65001 > $null
  ```
  **别搞反**：`[Console]::OutputEncoding` 管"读"，`$OutputEncoding` 管"写/发"。
- **诊断 JSON 是否损坏**：别用 `Get-Content`（默认 GBK 误报），用 `[IO.File]::ReadAllText(...,[Text.Encoding]::UTF8)`。
- **cmd/.bat 相反**：按 ANSI 解码 → 中文注释必须**纯 ASCII**，换行必须 **CRLF**（LF-only 会让 cmd 吞行首字符）。
- **BOM 会累积**：加 BOM 前先剥旧 BOM（否则多跑几次文件头全是 BOM）。
- **中文文件名**：命令行内联传中文路径易被 GBK 破坏 → 中文文件名/内容的处理**写进 Node 脚本内部**，别经命令行传参。
- **here-string `@'...'@` 偶发静默无输出** → 写 `.ps1`（UTF-8 带 BOM）再 `-File` 执行。
- **`-or`/`-and` 返回布尔**，不是短路取值：`($x -or '')` 是 `$True`，要 `if($x){$x}else{''}`。
- **`$ErrorActionPreference='Stop'` + 原生程序 stderr**：`2>&1` 收管道会让 stderr 变 ErrorRecord，Stop 下即抛。要么 `2>$null`，要么临时降 EAP。

---

## 二、Node 脚本编写

- 生成 JS 源码时，换行转义写 **`\\n`**（多一层，否则生成的脚本丢了反斜杠或提前断行）。
- 相对路径落在**启动/沙箱目录**，不是脚本所在目录 → 写项目文件用绝对路径或 `path.resolve(__dirname,...)`。
- 改 **CRLF** 文件用精确替换时，替换串里的换行必须 `\r\n`（否则把注释与代码合并成一行，`//` 吞掉声明）。
- JSON：`JSON.parse` → 改 → `JSON.stringify(obj,null,2)` 写回 → **写回后立刻再 `JSON.parse` 验证**（防双逗号/缺逗号）。
- 读 GBK 文件会乱码（需 iconv-lite）；读 UTF-8 用 `fs.readFileSync(p,'utf8')`。
- Windows 沙箱下 `child_process` 的 `stdio:'pipe'` 捕获输出可能 EPERM（命名管道被禁）→ 用 `stdio:'inherit'`/`'ignore'`，或 `execSync(...,{stdio:'inherit'})` + 关键输出 `fs.writeFileSync` 写文件绕开。

---

## 三、通用坑（跨语言）

- 工具/截图故障**禁止死磕**：立即终止 → 记台账 → 查资料 → 有边界修（2 次定位，失败即停）。
- 打包/构建**禁用 `-clean` 类清理**（会清空产物目录）。

---

*只做排障；完整工作纪律见 `skills/agentvane`。*
