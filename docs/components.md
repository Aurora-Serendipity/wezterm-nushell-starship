# 组件与配置详解

> 返回：[README](../README.md) · 相关：[架构](architecture.md) · [文件参考](file-reference.md)

## 1. WezTerm 配置

目录：`config/wezterm/`

### 1.1 入口 `wezterm.lua`

- 加载 `config/init.lua` 的累加器；
- 注册 4 个事件模块；
- 按顺序合并 6 个配置模块，返回 `config_builder` 构建的配置。

### 1.2 `config/` 模块

| 文件             | 主要内容                                                                                                                                                                                                                                                                                            |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `init.lua`       | `Config:init()/append()`、重复项告警、`config_builder` 校验                                                                                                                                                                                                                                         |
| `general.lua`    | `automatically_reload_config`、`exit_behavior=CloseOnCleanExit`、`scrollback_lines=5000`、`canonicalize_pasted_newlines=CarriageReturn`、`status_update_interval=1000`、超链接规则                                                                                                                  |
| `appearance.lua` | `color_scheme="Tokyo Night Moon"`、`colors` 覆盖、背景图层（居中裁剪 + hsb brightness 0.9）、`window_background_opacity=0.7`、一体化标题栏、`initial_cols=130` / `initial_rows=50`、`window_padding=6`、retro 标签栏（显示序号、`tab_max_width=25`）、滚动条、光标、`inactive_pane_hsb`、macOS 分支 |
| `fonts.lua`      | `CaskaydiaCove Nerd Font`、`font_size=13`                                                                                                                                                                                                                                                           |
| `launch.lua`     | `default_prog`（Nushell）、7 项 `launch_menu`（PowerShell/Cmd/pwsh/Nushell/3 个 WSL）                                                                                                                                                                                                               |
| `bindings.lua`   | leader `Ctrl+A`、35 条键位、`resize_pane` / `resize_font` 键表、4 条鼠标绑定（左键选中复制、Ctrl+左键开链接、右键粘贴、Shift+右键复制）                                                                                                                                                             |
| `domains.lua`    | 空的 SSH/Unix 域；3 个 WSL 域声明                                                                                                                                                                                                                                                                   |

### 1.3 `events/` 模块

| 文件                  | 作用                                                                                                      |
| --------------------- | --------------------------------------------------------------------------------------------------------- |
| `tab-title.lua`       | 自定义 `format-tab-title`：静态标题（铅笔图标 `U+F040`）、进程名、序号前缀、管理员标记、未读/活动三态配色 |
| `right-status.lua`    | 右侧日期时间 + 电池百分比（无电池时只显示时间）                                                           |
| `new-tab-button.lua`  | 标签栏"+"按钮：左键新建标签，右键弹启动器                                                                 |
| `window-position.lua` | `gui-startup`：普通启动 50% 居中；带 `--cwd` 启动时同样居中且保留 cmd 参数                                |

### 1.4 `colors/custom.lua`

只覆盖界面元素（不覆盖终端 ANSI 调色板）：

- 标签栏背景/活动/非活动/悬停/新建按钮；
- 滚动条、视觉铃、窗格分割线、输入法组合光标、选中文本。

所有色值来自 Tokyo Night Moon 色板。

### 1.5 `utils/`

| 文件           | 作用                            |
| -------------- | ------------------------------- |
| `platform.lua` | 平台判断（Windows/macOS/Linux） |
| `math.lua`     | `clamp` / `round`               |

### 1.6 背景图

- 仓库内 `backdrops/flower-meadow.jpg` 是**生成的 Tokyo Night 渐变占位图**（约 31 KB）；
- 用自己的壁纸覆盖同名文件即可获得本机截图效果；
- 背景亮暗由 `appearance.lua` 的 `hsb.brightness` 控制（默认 0.9）；
- 窗口整体透明度由 `window_background_opacity` 控制（默认 0.7）。

## 2. Nushell 配置

文件：`config/nushell/config.nu`（7 节）

| 节         | 内容                                                                                           | 说明                                     |
| ---------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------- |
| 1 主题     | `$env.config.color_config \| merge {hints, shape_matching_brackets}`                           | 只合并两处差异，保留 0.116 新增颜色键    |
| 2 提示符   | `$env.NU_EXPERIMENTAL_OPTIONS="native-clip"`；`mkdir`；`starship init nu \| save -f ...`       | 每次启动重新生成 Starship autoload       |
| 3 启动行为 | `show_banner=false`、`shell_integration.osc133=false`、`render_right_prompt_on_last_line=true` | 减少启动噪音、避免回车位移、右侧时间对齐 |
| 4 补全     | 12 条 `use` / `source`                                                                         | 见下文补全表                             |
| 5 别名     | `alias vim = nvim`；`def --wrapped cc`                                                         | AI CLI 包装                              |
| 6 代理     | 仅注释说明未采纳                                                                               | 不自动设置代理                           |
| 7 工具别名 | 仅注释说明未采纳                                                                               | 不绑定个人路径                           |

### 2.1 `env.nu`

保持 Nushell 默认模板（仅注释），不额外写环境变量。

### 2.2 补全表（`custom-completions/`）

| 工具   | 文件                           | 加载方式                  |
| ------ | ------------------------------ | ------------------------- |
| git    | `git/git-completions.nu`       | `use`                     |
| uv     | `uv/uv-completions.nu`         | `use`                     |
| npm    | `npm/npm-completions.nu`       | `use`                     |
| pnpm   | `pnpm/pnpm-completions.nu`     | `use`                     |
| cargo  | `cargo/cargo-completions.nu`   | `use`（子命令，无根命令） |
| rustup | `rustup/rustup-completions.nu` | `use`                     |
| docker | `docker/docker-completions.nu` | `use`                     |
| mvn    | `mvn/mvn-completions.nu`       | `source`（extern 未导出） |
| winget | `winget/winget-completions.nu` | `use`                     |
| ssh    | `ssh/ssh-completions.nu`       | `use`                     |
| vscode | `vscode/vscode-completions.nu` | `use`                     |
| rg     | `rg/rg-completions.nu`         | `use`                     |

来源：[nushell/nu_scripts](https://github.com/nushell/nu_scripts)（MIT）。

## 3. Starship 配置

文件：`config/starship.toml`

### 3.1 提示符格式

```
░▒▓ $os  $directory  $git_branch $git_status  语言…  $cmd_duration $jobs 
❯
```

右侧：`right_format = "$time"`，显示 `HH:MM`。

### 3.2 模块

| 模块                                                                           | 内容                                                          |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| `os`                                                                           | Windows/Linux/macOS 图标                                      |
| `directory`                                                                    | 路径（3 层截断）+ Documents/Downloads/Music/Pictures 图标替换 |
| `git_branch` / `git_status`                                                    | 分支与 `⇡ ⇣ ⇕ ≠ ✘ » ! ? ⚑` 状态符号                           |
| `nodejs` / `bun` / `rust` / `golang` / `c` / `cpp` / `php` / `python` / `java` | 语言图标 + 版本                                               |
| `docker_context`                                                               | `only_with_files=false`，context 非默认即显示                 |
| `cmd_duration`                                                                 | >500ms 显示耗时                                               |
| `jobs`                                                                         | 后台任务数                                                    |
| `time`                                                                         | 右侧时间                                                      |
| `character`                                                                    | 成功蓝 `❯`、失败红 `❯`、vim 模式紫 `❮`                        |

### 3.3 配色

- 背景三段：`#a3aed2` → `#769ff0` → `#394260` → `#212736` → `#1d2230`；
- 文字：`#e3e5e5` / `#769ff0` / `#a0a9cb`；
- 失败字符：`#ff757f`；vim：`#c099ff`。

## 4. 脚本

| 脚本                                 | 作用                          |
| ------------------------------------ | ----------------------------- |
| `scripts/install.ps1`                | 一键安装/备份/校验            |
| `scripts/verify.ps1`                 | 20+ 项健康检查                |
| `scripts/context-menu/install.ps1`   | 可选：Windows 11 一级右键菜单 |
| `scripts/context-menu/uninstall.ps1` | 卸载右键菜单                  |

## 5. 字体

- 字体：CaskaydiaCove Nerd Font（Nerd Fonts v3 字形集）；
- 字号：13；
- 缺失字形由 WezTerm 内置字体兜底；
- 字体不随仓库分发，安装脚本按需下载。

## 6. 可选：Windows 11 右键菜单

- 包：Custom Context Menu（LGPL-3.0）；
- 用户级开发者包，无需管理员；
- 配置 JSON 匹配 `Directory` + `Directory\Background`；
- 命令：`wezterm-gui.exe start --no-auto-connect --cwd "{path}"`；
- 经典入口保留。

## 7. 相关文档

- [文件参考](file-reference.md)
- [定制指南](customization.md)
- [排错手册](troubleshooting.md)

