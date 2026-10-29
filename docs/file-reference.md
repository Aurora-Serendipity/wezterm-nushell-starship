# 文件参考

> 返回：[README](../README.md)

## 1. 仓库结构

```text
wezterm-nushell-starship/
├─ README.md
├─ LICENSE                          MIT
├─ THIRD-PARTY-NOTICES.md           第三方来源与许可
├─ .gitignore
├─ config/
│  ├─ wezterm/
│  │  ├─ wezterm.lua                入口：合并模块 + 注册事件
│  │  ├─ config/
│  │  │  ├─ init.lua                累加器 + 重复项告警 + config_builder
│  │  │  ├─ general.lua             行为/回滚/粘贴/超链接
│  │  │  ├─ appearance.lua          配色/背景/窗口/标签栏/光标
│  │  │  ├─ fonts.lua               字体/字号/连字
│  │  │  ├─ launch.lua              默认 shell + 启动菜单
│  │  │  ├─ bindings.lua            leader/键位/key tables/鼠标
│  │  │  └─ domains.lua             WSL/SSH/Unix 域
│  │  ├─ events/
│  │  │  ├─ window-position.lua     启动居中 + cwd 感知
│  │  │  ├─ tab-title.lua           标签标题
│  │  │  ├─ right-status.lua        右侧时间/电池
│  │  │  └─ new-tab-button.lua      "+"按钮行为
│  │  ├─ colors/custom.lua          界面元素配色覆盖
│  │  ├─ utils/{platform,math}.lua  工具函数
│  │  ├─ backdrops/flower-meadow.jpg 本机背景图
│  │  ├─ README.md                  模块说明（原项目文档）
│  │  ├─ THIRD-PARTY-NOTICES.md     WezTerm 配置的第三方声明
│  │  └─ .editorconfig/.gitattributes/.gitignore/.luarc.json/.stylua.toml/selene.toml
│  ├─ nushell/
│  │  ├─ config.nu                  9 节 Nushell 配置
│  │  ├─ env.nu                     默认 env 模板
│  │  └─ custom-completions/        12 组补全 + README
│  └─ starship.toml                 Powerline 提示符配置
├─ scripts/
│  ├─ install.ps1                   一键安装/备份/校验/可选右键菜单
│  ├─ verify.ps1                    健康检查
│  ├─ README.md                     脚本说明
│  └─ context-menu/
│     ├─ install.ps1                安装 Windows 11 一级右键菜单
│     ├─ uninstall.ps1              卸载
│     └─ README.md                  说明与许可
└─ docs/
   ├─ overview.md                   方案总览
   ├─ architecture.md               架构与加载流程
   ├─ installation.md               安装/升级/回滚
   ├─ usage.md                      使用手册
   ├─ components.md                 组件详解
   ├─ customization.md              定制指南
   ├─ faq.md                        常见问题
   ├─ troubleshooting.md            排错
   ├─ design.md                     设计取舍
   ├─ changelog.md                  变更记录
   ├─ terminal-art.md               终端艺术工具与玩法
   ├─ file-reference.md             本文件
   └─ images/{wezterm-window,context-menu}.png
```

## 2. 关键配置项速查（WezTerm）

| 配置                            | 值                           | 文件                    |
| ------------------------------- | ---------------------------- | ----------------------- |
| `color_scheme`                  | `Tokyo Night Moon`           | `config/appearance.lua` |
| `window_background_opacity`     | `0.7`                        | 同上                    |
| `background[1].hsb.brightness`  | `0.9`                        | 同上                    |
| `window_decorations`            | `INTEGRATED_BUTTONS\|RESIZE` | 同上                    |
| `initial_cols` / `initial_rows` | `130` / `50`                 | 同上                    |
| `use_fancy_tab_bar`             | `false`                      | 同上                    |
| `hide_tab_bar_if_only_one_tab`  | `false`                      | 同上                    |
| `default_cursor_style`          | `BlinkingBlock`              | 同上                    |
| `font`                          | `CaskaydiaCove Nerd Font`    | `config/fonts.lua`      |
| `font_size`                     | `13`                         | 同上                    |
| `harfbuzz_features`             | `calt=1`、`liga=1`、`clig=1` | 同上                    |
| `default_prog`                  | Nushell                      | `config/launch.lua`     |
| `leader`                        | `Ctrl+A`                     | `config/bindings.lua`   |
| `mouse_bindings`                | 4 条                         | 同上                    |
| `automatically_reload_config`   | `true`                       | `config/general.lua`    |
| `exit_behavior`                 | `CloseOnCleanExit`           | 同上                    |
| `scrollback_lines`              | `5000`                       | 同上                    |
| `status_update_interval`        | `1000`                       | 同上                    |

## 3. 关键配置项速查（Nushell）

| 配置              | 值                                                | 位置    |
| ----------------- | ------------------------------------------------- | ------- |
| 颜色合并          | `hints=#6c6c6c`、`shape_matching_brackets.attr=u` | 第 1 节 |
| 剪贴板            | `NU_EXPERIMENTAL_OPTIONS = "native-clip"`         | 第 2 节 |
| Starship autoload | `starship init nu \| save -f`                     | 第 2 节 |
| banner            | `show_banner=false`                               | 第 3 节 |
| 回车位移          | `shell_integration.osc133=false`                  | 第 3 节 |
| 右侧提示符        | `render_right_prompt_on_last_line=true`           | 第 3 节 |
| 补全              | 12 条 use/source                                  | 第 4 节 |
| vim               | `alias vim = nvim`                                | 第 5 节 |
| cc                | `def --wrapped cc`                                | 第 5 节 |
| 终端艺术          | `img` / `art` / `banner`                          | 第 8 节 |
| 表格视觉          | `header_on_separator=true`、`missing_value_symbol=·` | 第 9 节 |
| Python 编码       | `PYTHONIOENCODING=utf-8`                          | 第 9 节 |

## 4. Starship 模块

`format` 顺序：

`os` → `directory` → `git_branch`/`git_status` → `nodejs`/`bun`/`rust`/`golang`/`c`/`cpp`/`php`/`python`/`java`/`docker_context` → `cmd_duration`/`jobs` → `character`

`right_format = "$time"`。

## 5. 脚本参数

### `scripts/install.ps1`

| 参数                 | 说明             |
| -------------------- | ---------------- |
| `-SkipFont`          | 跳过字体         |
| `-WithContextMenu`   | 同时安装右键菜单 |
| `-NoRestartExplorer` | 不重启资源管理器 |
| `-DryRun`            | 只打印计划       |

### `scripts/verify.ps1`

| 参数              | 说明                     |
| ----------------- | ------------------------ |
| `-WezTermConfig`  | 自定义 WezTerm 配置路径  |
| `-NuConfig`       | 自定义 Nushell 配置路径  |
| `-StarshipConfig` | 自定义 Starship 配置路径 |

### `scripts/context-menu/install.ps1`

| 参数                 | 说明                        |
| -------------------- | --------------------------- |
| `-WezTermGuiPath`    | 指定 `wezterm-gui.exe` 路径 |
| `-PackageDir`        | 离线包目录（已解压）        |
| `-NoRestartExplorer` | 不重启资源管理器            |

### `scripts/context-menu/uninstall.ps1`

| 参数                 | 说明             |
| -------------------- | ---------------- |
| `-NoRestartExplorer` | 不重启资源管理器 |

## 6. 生成文件（不提交仓库）

| 文件                                            | 说明                       |
| ----------------------------------------------- | -------------------------- |
| `%APPDATA%\nushell\vendor\autoload\starship.nu` | 每次启动 Nushell 重新生成  |
| `*.bak-<时间戳>`                                | 安装脚本备份               |
| `config/nushell/history.txt`                    | Nushell 历史（.gitignore） |



