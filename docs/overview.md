# 方案总览

> 返回：[README](../README.md) · 下一篇：[架构与加载流程](architecture.md)

## 1. 这是什么

这是一套在 **Windows 11** 上长期使用并经过完整验证的终端配置，由三部分组成：

| 层         | 软件                        | 职责                                                               |
| ---------- | --------------------------- | ------------------------------------------------------------------ |
| 终端外壳   | **WezTerm**                 | 窗口、标签、窗格、字体、背景、配色、鼠标/键盘、WSL 域、启动器      |
| Shell      | **Nushell 0.116**           | 命令行体验：提示符、补全、别名、AI CLI 包装、右侧提示符            |
| 提示符引擎 | **Starship 1.27**           | Powerline 风格 prompt：目录、Git、语言版本、耗时、任务数、右侧时间 |
| 字体       | **CaskaydiaCove Nerd Font** | 图标与 Powerline 分隔符                                            |
| 可选       | **Custom Context Menu**     | Windows 11 一级右键菜单项 `Open WezTerm here`                      |

## 2. 设计目标

1. **完整覆盖原配置**：从旧的单文件 WezTerm 配置迁移时，原有 19 个显式选项、23 条按键、
   2 条鼠标绑定、窗口启动逻辑全部保留，并以 `show-keys` + 配置快照对比验证。
2. **模块化、可维护**：WezTerm 配置按职责拆分成 `config/` + `events/` + `colors/` + `utils/`，
   避免一个上千行的单文件；Nushell 则保持单文件但按 7 个功能节组织。
3. **Windows 优先**：WSL 标签页/域、资源管理器右键菜单、Windows 字体/路径、输入法/复制粘贴行为都按 Windows 适配。
4. **可回滚**：所有安装动作自动备份；旧经典右键入口保留；配置改动可以 git 回退。
5. **可验证**：提供 `scripts/verify.ps1`，一键检查软件、字体、配置加载、键位、补全、提示符与右键菜单。
6. **不改变系统级行为**：不修改 PowerShell profile、不自动设代理、不自动接受 AI CLI 危险参数、不默认提权。

## 3. 能力矩阵

| 能力                                  | 状态 | 位置                                      |
| ------------------------------------- | ---- | ----------------------------------------- |
| 模块化 WezTerm 配置 + 热重载          | ✅   | `config/wezterm/`                         |
| Tokyo Night Moon + 自定义覆盖         | ✅   | `colors/custom.lua`                       |
| 背景图层（透明度/亮度/对齐）          | ✅   | `config/appearance.lua`                   |
| 一体化细标题栏                        | ✅   | `config/appearance.lua`                   |
| Retro Powerline 标签栏 + 序号         | ✅   | `appearance.lua` + `events/tab-title.lua` |
| 增强标签标题（进程/静态/管理员/未读） | ✅   | `events/tab-title.lua`                    |
| 右侧时间 + 电池状态                   | ✅   | `events/right-status.lua`                 |
| 标签栏"+"按钮右键启动器               | ✅   | `events/new-tab-button.lua`               |
| 启动居中 + cwd 感知（右键打开）       | ✅   | `events/window-position.lua`              |
| 35 条键盘绑定 + key tables            | ✅   | `config/bindings.lua`                     |
| 鼠标右键粘贴 / Shift+右键复制         | ✅   | `config/bindings.lua`                     |
| 7 项启动菜单 + 3 个 WSL 域            | ✅   | `config/launch.lua`、`config/domains.lua` |
| Nushell 8 节配置                      | ✅   | `config/nushell/config.nu`                |
| 12 组命令补全                         | ✅   | `config/nushell/custom-completions/`      |
| Starship Powerline + 右侧时间         | ✅   | `config/starship.toml`                    |
| `vim` → `nvim` 别名                   | ✅   | `config.nu` 第 5 节                       |
| `cc`：Claude Code 包装 + 改标签名     | ✅   | `config.nu` 第 5 节                       |
| 终端艺术 `img`/`art`/`banner`（可选） | ✅   | `config.nu` 第 8 节                       |
| Windows 11 一级右键菜单（可选）       | ✅   | `scripts/context-menu/`                   |
| 一键安装 + 自动备份                   | ✅   | `scripts/install.ps1`                     |
| 健康检查                              | ✅   | `scripts/verify.ps1`                      |
| 完整中文技术文档                      | ✅   | `docs/`                                   |

## 4. 适用人群

- Windows 11 上希望"一套配置直接可用"的开发者；
- 想要模块化 WezTerm 配置，但不想从零搭建的人；
- 喜欢 Tokyo Night / Powerline / Nerd Font 风格的人；
- 需要 WSL、多标签、多窗格、Git 状态提示符的人；
- 想把 `Open WezTerm here` 放进 Windows 11 一级右键菜单的人。

## 5. 与其它方案的差异

| 方案                           | 优点           | 不足                                  | 本方案选择                         |
| ------------------------------ | -------------- | ------------------------------------- | ---------------------------------- |
| 终端默认配置                   | 零配置         | 没有标签标题、状态栏、补全、主题      | 不采用                             |
| 单文件 WezTerm 配置            | 简单           | 难维护、容易膨胀                      | 改为模块化                         |
| oh-my-posh 提示符              | 生态大、模板多 | 与 Starship 功能重叠、额外引擎        | 使用 Starship                      |
| 第三方主题管理器（如 stellar） | 换主题方便     | 引入额外依赖，配色难统一              | 不采用，直接维护 Tokyo Night       |
| Windows Terminal               | 系统自带       | 标签/窗格/字体/配置自由度不如 WezTerm | 使用 WezTerm                       |
| 恢复 Windows 10 经典右键菜单   | 一行注册表     | 整个菜单变旧样式                      | 不默认采用；用打包扩展实现一级菜单 |

## 6. 版本基线

| 组件        | 实测版本                             |
| ----------- | ------------------------------------ |
| OS          | Windows 11 26H2 build 26300.9457     |
| WezTerm     | nightly 20261010-083911-e2a98e1b     |
| Nushell     | 0.116.1                              |
| Starship    | 1.27.0                               |
| Neovim      | 0.12.6（可选）                       |
| Claude Code | 2.1.310（可选）                      |
| Nerd Fonts  | CaskaydiaCove Nerd Font（v3 字形集） |

## 7. 非目标

- 不支持 Windows 10 的"新右键菜单"（Windows 10 本身没有该机制；经典入口仍可用）。
- 不在安装脚本里自动安装/登录 Claude Code（涉及账号与许可）。
- 不默认开启代理、不自动修改系统代理设置。
- 不提供 macOS/Linux 的完整等价方案（配置里有平台分支，但主要面向 Windows）。

## 8. 继续阅读

- [架构与加载流程](architecture.md)
- [安装与升级](installation.md)
- [使用手册](usage.md)
- [组件与配置详解](components.md)
- [终端艺术玩法](terminal-art.md)

