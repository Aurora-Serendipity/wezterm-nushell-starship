# WezTerm 配置（多文件版）

本目录是 WezTerm 的模块化配置（仓库中的 `config/wezterm/`），组织方式参考开源项目
[QianSong1/wezterm-config](https://github.com/QianSong1/wezterm-config)（MIT），
在此基础上保留并迁移了原有单文件配置（`~/.wezterm.lua`）的全部内容，再按需补充了若干增强项；
后续迭代还借鉴了 [dqtx760/wezterm-kit](https://github.com/dqtx760/wezterm-kit)（MIT）的少量配置项。

## 配置位置与加载

- 生效入口：`%USERPROFILE%\.config\wezterm\wezterm.lua`（仓库根目录的 `scripts/install.ps1` 会把它复制到此处）
- 若已存在旧配置，安装脚本会先备份为 `*.bak-<时间戳>`；旧的单文件 `%USERPROFILE%\.wezterm.lua`
  若存在，本目录路径优先。
- 修改**入口文件**会触发热重载；修改 `config/`、`events/` 等子模块后若未自动生效，
  按 `Ctrl+Shift+Alt+R` 手动重载配置（`Ctrl+Shift+R` 已用于"重命名标签页"）。
- 本目录是仓库的一部分，可直接 `git log` / `git diff` 查看历次改动。

## 目录结构

```
wezterm.lua                  入口：按顺序合并 config/ 模块，并注册 events/ 事件
config/
  init.lua                   Config:init()/append() 累加器（重复项告警 + config_builder 校验）
  general.lua                行为、回滚缓冲、粘贴、超链接规则
  appearance.lua             配色/背景/窗口/标签栏/滚动条/光标
  fonts.lua                  字体与字号
  launch.lua                 默认 shell 与启动菜单
  bindings.lua               键位、key tables、鼠标绑定
  domains.lua                多路复用域（WSL 发行版）
colors/
  custom.lua                 Tokyo Night Moon 之上的界面元素配色覆盖
events/
  window-position.lua        启动窗口定位（原 gui-startup 逻辑 + cwd 感知/带参数居中）
  tab-title.lua              增强标签标题（序号/进程/未读/管理员/三态配色）
  right-status.lua           右侧状态栏（日期时间 + 电池）
  new-tab-button.lua         标签栏"+"按钮：右键弹启动器
utils/
  platform.lua               平台判断（Windows/macOS/Linux）
  math.lua                   数值 clamp/round
backdrops/
  flower-meadow.jpg          窗口背景图（仓库内含本机壁纸，可替换）
.editorconfig / .gitignore / .luarc.json / .stylua.toml / selene.toml
THIRD-PARTY-NOTICES.md       参考项目的 MIT 许可与改编说明
```

## 快捷键

### 原有绑定（全部保留）

| 快捷键              | 功能                                       |
| ------------------- | ------------------------------------------ |
| `Ctrl+Q`            | 退出 WezTerm                               |
| `Ctrl+A`（Leader）  | 前缀键，1 秒超时                           |
| `Leader` `h` / `v`  | 左右 / 上下分屏                            |
| `Leader` `q`        | 关闭当前窗格                               |
| `Ctrl+方向键`       | 在窗格间移动                               |
| `Ctrl+T` / `Ctrl+W` | 新建 / 关闭标签页                          |
| `Ctrl+1` … `Ctrl+8` | 切换到第 1–8 个标签页                      |
| `Ctrl+Shift+1/2/3`  | 新建 WSL Ubuntu-24.04 / Kali / Arch 标签页 |
| `Ctrl+Shift+4/5`    | 新建 cmd / pwsh 标签页                     |
| 鼠标左键松开        | 选中即复制到剪贴板 + 主选区                |
| `Ctrl+左键`         | 打开鼠标下的超链接                         |

### 新增绑定

| 快捷键                          | 功能                                 |
| ------------------------------- | ------------------------------------ |
| `F1`                            | 进入复制模式（Copy Mode）            |
| `F2`                            | 命令面板                             |
| `F3`                            | 启动器（搜索/启动菜单/域）           |
| `F4`                            | 标签页导航器                         |
| `F11` / `F12`                   | 全屏 / 调试面板                      |
| `Ctrl+Shift+C` / `Ctrl+Shift+V` | 复制 / 粘贴（与默认一致，显式声明）  |
| `Ctrl+Shift+R`                  | 重命名当前标签页                     |
| `Ctrl+Shift+Alt+R`              | 重载配置                             |
| `Leader` `p` 后 `h/j/k/l`       | 调整窗格尺寸，`q`/`Esc` 退出         |
| `Leader` `f` 后 `k/j/r`         | 放大/缩小/重置字号，`q`/`Esc` 退出   |
| 鼠标右键                        | 粘贴（来自 wezterm-kit）             |
| `Shift`+鼠标右键                | 复制当前选中内容（来自 wezterm-kit） |

## 启动器与域

- 启动菜单：PowerShell、Cmd、PowerShell v7、Nushell、WSL Ubuntu-24.04 / Kali / Arch。
- WSL 域：`WSL:Ubuntu-24.04`、`WSL:kali-linux`、`WSL:archlinux`（供 `F3` 启动器与"+"右键菜单使用）。
- 默认 shell 仍为 Nushell（`nu.exe` 绝对路径）。
- 标签栏"+"按钮：左键新建标签，右键弹出启动器（模糊搜索 + 启动菜单 + 域）。
- 启动行为：普通启动沿用"活动屏 50% 居中"；从资源管理器右键 "Open WezTerm here" 启动时会传入 `--cwd`，
  窗口同样居中且 Nushell 直接落在目标目录。

## 外观

- 配色：内置 `Tokyo Night Moon`，`colors/custom.lua` 只覆盖标签栏/滚动条/选区等界面元素。
- 背景：`backdrops/flower-meadow.jpg` + 窗口透明度 0.7；背景图层居中裁剪，`hsb.brightness = 0.9` 可单独调暗（改 `config/appearance.lua`）。
  仓库内含本机使用的背景图，可直接用同名文件替换成自己的壁纸。
- 窗口：一体化细标题栏（`INTEGRATED_BUTTONS|RESIZE`），Windows 风格按钮。
- 标签栏：retro 模式（非 fancy），带序号与进程名的 Powerline 标签，`tab_max_width = 25`。
- 右侧状态栏：日期时间 + 电池（无电池设备自动只显示时间）。
- 滚动条、窗口内边距、光标闪烁等均已按参考方案配置。

## 与旧单文件配置的差异（有意变更）

1. `window_decorations`：`TITLE | RESIZE` → `INTEGRATED_BUTTONS|RESIZE`（用户确认采用一体化标题栏）。
2. 背景图：`D:\桌面迁移\...\Flower meadow.jpg` → `backdrops/flower-meadow.jpg`（配置自包含）。
3. 启动菜单：修正 `PoserShell` 拼写，并新增 PowerShell v7 / Nushell / 三个 WSL 入口。
4. 新增功能项：见"新增绑定"、"外观"、`general.lua`（`exit_behavior`、5000 行回滚、超链接规则等）。
5. `macos_window_background_blur` 在 macOS 平台分支中保留（Windows 下原本就不生效）。
6. 借鉴 wezterm-kit（MIT）：鼠标右键粘贴 / `Shift`+右键复制、启动时 cwd 感知且带参数也居中、
   背景图层对齐/hsb、Nushell `cc` 包装、Starship `c`/`cpp` 模块、健康检查脚本。
7. Windows 11 右键菜单：用 Custom Context Menu（LGPL-3.0，独立安装包）把 "Open WezTerm here"
   提升到新菜单一级；旧经典注册表入口保留（"显示更多选项"）。

除此之外，旧配置的 19 个显式选项、23 条按键、2 条鼠标绑定、窗口居中逻辑均逐一保留；
改造过程已用"旧配置有效配置 JSON 快照 vs 新配置快照"的自动 diff 与 `show-keys` 对比验证（PASS）。

## 备份与回滚

- 安装脚本在覆盖前会自动备份：被替换的目录/文件改名为 `*.bak-<时间戳>`。
- 手动回滚：把备份目录/文件改回原名，重启 WezTerm 即可。
- 也可以用仓库的 git 历史回退配置后重新运行安装脚本。

## 健康检查

终端环境与三份配置的一键体检（参考 wezterm-kit 的 `verify.ps1` 组织方式）：

```powershell
# 在仓库根目录执行
pwsh -File .\scripts\verify.ps1
```

覆盖软件/字体/配置加载/键位覆盖/Nushell/Starship/补全/跨组件集成，以及可选的 Windows 右键菜单检查。

## Windows 11 右键菜单（一级）

Windows 11 的新右键菜单只接受带包身份的 `IExplorerCommand` 扩展，WezTerm 安装器写入的经典
`Directory\shell` / `Directory\Background\shell` 项只能出现在"显示更多选项"里。
仓库提供可选脚本，用开源工具 [Custom Context Menu](https://github.com/ikas-mc/ContextMenuForWindows11)（LGPL-3.0，
用户级开发者松散包，无需管理员）把 **Open WezTerm here** 提升到一级菜单，文件夹空白处与文件夹上均可用；
旧经典入口保留作为回退。

维护脚本与说明：`scripts/context-menu/`（`install.ps1` / `uninstall.ps1` / `README.md`）。

## 第三方声明

参考项目为 MIT 许可：QianSong1/wezterm-config（Copyright (c) 2023 Kevin Silvester）、
[wezterm-kit](https://github.com/dqtx760/wezterm-kit)（Copyright (c) 2026 DQTX）。
Windows 右键菜单使用 [Custom Context Menu](https://github.com/ikas-mc/ContextMenuForWindows11)（LGPL-3.0，
仅安装使用其发布包，未复制代码）。详见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。


