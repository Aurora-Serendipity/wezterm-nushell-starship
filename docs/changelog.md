# 变更记录

> 返回：[README](../README.md) · 相关：[设计取舍](design.md)

本文件记录从"单文件终端配置"演进到本仓库的完整过程。时间为本机实际改造时间（Asia/Shanghai）。

## 时间线总览

| 日期       | 阶段                    | 结果                                                         |
| ---------- | ----------------------- | ------------------------------------------------------------ |
| 2026-10-24 | WezTerm 单文件 → 模块化 | 19 项配置、23 条按键、2 条鼠标绑定、窗口逻辑全部保留         |
| 2026-10-25 | Nushell 方案落地        | 0.116 单文件 7 节、native-clip、Starship autoload、12 组补全 |
| 2026-10-25 | Starship 增强           | 官方 tokyo-night 预设 + 语言/耗时/任务/右侧时间/c-cpp        |
| 2026-10-25 | 借鉴 wezterm-kit        | 右键粘贴、cwd 感知启动、背景 hsb、`cc`、c/cpp、健康检查      |
| 2026-10-25 | Windows 11 一级右键菜单 | 打包扩展方案落地，`Open WezTerm here` 进入一级菜单           |
| 2026-10-25 | 开源仓库整理            | 文档、安装/校验脚本、截图、占位背景图                        |

## 阶段 1：WezTerm 模块化（2026-10-24）

**起点**：`%USERPROFILE%\.wezterm.lua` 单文件配置。

**目标**：保持行为完全不变，迁移到多文件结构。

**做法**：

- 参考 `QianSong1/wezterm-config`（MIT）；
- 入口 `wezterm.lua` 只负责合并 `config/` 模块与注册 `events/`；
- 迁移时逐项保留：19 个显式选项、23 条按键、2 条鼠标绑定、窗口居中 `gui-startup`；
- 原背景图从 `D:\桌面迁移\...` 复制到 `backdrops/`，实现配置自包含；
- 使用"旧配置有效配置 JSON 快照 vs 新配置快照"与 `show-keys` 做 diff 验证。

**结果**：`b2f6a09 迁移为多文件配置（参考 QianSong1/wezterm-config）`。

**有意变更**：

- 标题栏改为一体化细标题栏（用户确认）；
- 启动菜单修正 `PoserShell` 拼写并补充 pwsh/Nushell/WSL 入口；
- 增加 F1–F4/F11/F12、复制粘贴显式绑定、标签重命名、重载配置、leader key tables。

## 阶段 2：Nushell 配置（2026-10-25）

**目标**：保留原有 `native-clip` 与 Starship 自动生成机制，按功能分节组织。

**做法**：

- 参考 `Byxs20/terminal_config` 的 Nushell 单文件分节方式；
- 7 节：主题 merge、Starship autoload、启动行为、补全、别名、代理（未采纳）、工具别名（未采纳）；
- 保留 `$env.NU_EXPERIMENTAL_OPTIONS = "native-clip"`；
- 每次启动 `starship init nu | save -f`；
- 添加 `render_right_prompt_on_last_line = true`；
- 从 `nu_scripts`（MIT）引入 12 组补全，其中 `mvn` 用 `source`；
- 添加 `alias vim = nvim`。

**结果**：`%APPDATA%\nushell\config.nu` 单文件 7 节；补全目录 12 组。

## 阶段 3：Starship 增强（2026-10-25）

**目标**：在官方 tokyo-night 预设基础上增强 Powerline 提示符。

**做法**：

- `starship preset tokyo-night` 作为基线；
- 新增 `python` / `java` / `docker_context` / `cmd_duration` / `jobs`；
- `git_status` 使用 `⇡ ⇣ ⇕ ≠ ✘ » ! ? ⚑` 细分；
- 时间移到 `right_format`；
- `character` 三态配色（成功蓝/失败红/vim 紫）；
- 备份原配置为 `starship.toml.bak-20261025`。

## 阶段 4：借鉴 wezterm-kit（2026-10-25）

**来源**：`dqtx760/wezterm-kit`（MIT）。

**采纳**：

- 鼠标右键粘贴 / `Shift`+右键复制；
- `gui-startup` 的 cwd 感知 + 带参数也居中（保留原 50% 尺寸与 cmd 参数）；
- 背景图层居中裁剪 + `hsb.brightness = 0.9`（窗口透明度 0.7 不变）；
- Nushell `cc`（Claude Code 包装 + 标签改名）；
- Starship `c` / `cpp` 模块；
- 健康检查脚本的检查项组织方式。

**未采纳**：

- `exit_behavior = "Hold"`（与已确认的 `CloseOnCleanExit` 冲突）；
- 无标题栏 `RESIZE`、单标签隐藏标签栏；
- 自动代理/代理开关、AI CLI 自动接受参数；
- 把 AI CLI 放进 `gui-startup`。

**结果**：`80989c9 借鉴 wezterm-kit...`；健康检查脚本 28 项全部通过，旧键位零丢失（`show-keys` 311 行基线全部保留）。

## 阶段 5：Windows 11 一级右键菜单（2026-10-25）

**问题**：WezTerm 安装器写入的经典 `Directory\Background\shell` 项在 Windows 11 只能进"显示更多选项"。

**调研**：

- Windows 11 新菜单只接受带包身份、实现 `IExplorerCommand` 的扩展；
- Microsoft Store 的 Custom Context Menu 安装失败（`0x803f8001`，账号/区域限制）；
- 改用 GitHub Release 的 DEV 包，利用开发者模式做用户级松散注册，无需管理员。

**实现**：

- 包：`91b3cc93-5e27-4b3e-9d97-dd137b7fb3ea` v5.9.0.53；
- 安装到 `%LOCALAPPDATA%\Programs\ContextMenuCustomDev`；
- 配置写入包内 `LocalState\custom_commands`；
- 匹配文件夹空白处 + 文件夹；
- 命令：`wezterm-gui.exe start --no-auto-connect --cwd "{path}"`；
- 实测一级菜单出现 `Open WezTerm here`，点击后正确落在目标目录。

**文档**：`0332ff8 文档：记录 Windows 11 一级右键菜单（Open WezTerm here）方案`。

## 阶段 6：整理为开源仓库（2026-10-25）

**新增**：

- 完整技术文档（本 `docs/`）；
- 一键安装脚本 `scripts/install.ps1`（依赖、字体、备份、复制、路径修正、可选右键菜单、校验）；
- 健康检查 `scripts/verify.ps1`（20+ 项）；
- 可选右键菜单安装/卸载脚本；
- 干净截图；
- 生成式占位背景图（不包含个人壁纸）；
- MIT License 与第三方声明。

**兼容性处理**：

- WezTerm `launch.lua` 的 Nu 路径改为 `wezterm.home_dir`（安装脚本仍会按实际路径修正）；
- 右键菜单脚本自动探测 `wezterm-gui.exe`；
- 文档标注 WSL 发行版、路径、壁纸需要按本机调整。

## 版本矩阵（发布时）

| 组件        | 版本                             |
| ----------- | -------------------------------- |
| Windows     | 11 26H2 build 26300.9457         |
| WezTerm     | nightly 20261010-083911-e2a98e1b |
| Nushell     | 0.116.1                          |
| Starship    | 1.27.0                           |
| Neovim      | 0.12.6                           |
| Claude Code | 2.1.310                          |
| Nerd Fonts  | CaskaydiaCove（v3）              |

## 验证摘要

- WezTerm 配置加载无 ERROR/WARN；`show-keys` 基线行全部保留；
- Nushell 配置可加载；`native-clip`、right prompt、`cc`、12 组合集补全；
- Starship 左右提示符正常；c/cpp 模块在对应目录出现；
- 健康检查 31 项全部通过（含可选右键菜单检查）；
- Windows 11 右键菜单一级项实测可用；
- 安装脚本离线模式重装实测通过。

## 已知问题

- 右键菜单 DEV 包需要开发者模式；
- 字体/右键菜单包依赖 GitHub 下载；
- 截图使用个人壁纸，仓库不包含该图；
- WSL 发行版名称是示例；
- Windows 10 不支持新右键菜单机制。

