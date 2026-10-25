# 设计取舍

> 返回：[README](../README.md) · 相关：[架构](architecture.md) · [变更记录](changelog.md)

## 1. 设计原则

1. **先覆盖，再增强**：任何优化都必须先完整保留原有配置；
2. **模块化优先**：WezTerm 按职责拆文件；Nushell 保持单文件但按功能分节；
3. **Windows 原生体验**：WSL、资源管理器右键、字体安装、PATH、输入法都按 Windows 习惯；
4. **可回滚**：安装/修改前自动备份；可选功能可独立卸载；
5. **默认安全**：不自动提权、不自动设代理、不自动接受 AI CLI 危险参数；
6. **可验证**：能用命令检查的，不靠"看起来没问题"。

## 2. 关键取舍

### 2.1 WezTerm：模块化 vs 单文件

| 方案               | 优点                         | 缺点                                     |
| ------------------ | ---------------------------- | ---------------------------------------- |
| 单文件             | 简单、复制方便               | 容易膨胀到上千行、难定位、多人协作冲突多 |
| **模块化（采用）** | 职责清晰、易定位、可单独测试 | 需要理解加载顺序                         |

采用参考项目 `QianSong1/wezterm-config` 的组织方式：入口只负责合并与注册事件，配置按功能拆到
`config/`、`events/`、`colors/`、`utils/`。同时保留 `config/init.lua` 的重复项告警与 `config_builder` 校验，
避免模块化带来的隐性冲突。

### 2.2 Nushell：单文件分节 vs 多模块

| 方案                    | 优点                             | 缺点                                      |
| ----------------------- | -------------------------------- | ----------------------------------------- |
| 多文件                  | 更细粒度                         | Nushell 的模块/作用域机制会引入额外复杂度 |
| **单文件 7 节（采用）** | 易读、易复制、与社区常见方案一致 | 文件会变长（当前 ~92 行）                 |

采用 `Byxs20/terminal_config` 的"按功能分节"思路，但只保留适合本机的内容，没有复制其个人路径/代理/CTF 别名。

### 2.3 提示符：Starship vs oh-my-posh vs 自绘

| 方案                  | 优点                               | 缺点                                |
| --------------------- | ---------------------------------- | ----------------------------------- |
| oh-my-posh            | 生态大、模板多                     | 额外引擎、配置体系不同              |
| 自绘 `PROMPT_COMMAND` | 完全可控                           | 需要自己处理 width/异步/耗时/任务数 |
| **Starship（采用）**  | 跨 shell、模块化、Nushell 官方集成 | 需要 Nerd Font                      |

采用 Starship 官方 `tokyo-night` 预设并增强，保留 `starship init nu` 的自动生成机制（不手写 `PROMPT_COMMAND`），
这样耗时、任务数、宽度等信息由 Starship/Nushell 集成自动提供。

### 2.4 配色：Tokyo Night Moon + 最小覆盖

- 终端 ANSI 调色板用内置 `Tokyo Night Moon`；
- 只覆盖标签栏/滚动条/选区等界面元素（`colors/custom.lua`）；
- 不整份重写 `color_config`，避免丢失 Nushell 新版本颜色键。

### 2.5 背景：透明度 + 图层 hsb

- `window_background_opacity = 0.7`：保留原配置的整体透明观感；
- 背景图层居中裁剪 + `hsb.brightness = 0.9`：单独压暗背景图，不影响文字；
- 不把背景图复制到 `%LOCALAPPDATA%\wezterm-kit` 之类的外部目录，保持配置自包含（`backdrops/`）。

### 2.6 标题栏与标签栏

- 一体化细标题栏（`INTEGRATED_BUTTONS|RESIZE`）：接近 Windows 11 原生观感；
- retro 标签栏（非 fancy）+ 序号 + Powerline 标签：信息密度高、与自定义 cell 配色统一；
- 单标签时**不隐藏**标签栏：方便始终看到标签状态（原配置行为）。

### 2.7 键位：Leader 用 Ctrl+A，不移植 Alt 组合

- `Ctrl+A` 作为 leader 与 tmux 习惯一致；
- 参考方案的整套 Alt 键位在 Windows 上容易与输入法/菜单冲突，因此只追加 F1–F4/F11/F12 与 key tables；
- `Ctrl+Shift+R` 用作重命名标签，因此重载配置改为 `Ctrl+Shift+Alt+R`。

### 2.8 启动行为：50% 居中 + cwd 感知

- 普通启动：活动屏 50% 居中（原配置行为）；
- 带 `--cwd` 启动（资源管理器右键 "Open WezTerm here"）：同样居中，直接落在目标目录；
- 保留原 `cmd` 参数（`-e` 等）不被吞掉。

### 2.9 Windows 11 右键菜单：打包扩展 vs 恢复经典菜单

| 方案                     | 优点                               | 缺点                                         |
| ------------------------ | ---------------------------------- | -------------------------------------------- |
| 恢复经典菜单（改 CLSID） | 一行注册表                         | 整个右键菜单变 Windows 10 样式，影响所有软件 |
| **打包扩展（采用）**     | 保留 Windows 11 新菜单，仅增加一项 | 需要安装第三方开源包；可选、可卸载           |
| 不改                     | 零风险                             | `Open WezTerm here` 永远在"显示更多选项"里   |

采用可选安装的打包扩展方案：使用 LGPL-3.0 的 Custom Context Menu 开发者包做用户级松散注册，
无需管理员；旧经典入口保留作为回退。

## 3. 没有采纳的内容

| 内容                                                       | 原因                                                     |
| ---------------------------------------------------------- | -------------------------------------------------------- |
| `exit_behavior = "Hold"`                                   | 与已确认的 `CloseOnCleanExit` 冲突，退出后残留进程不友好 |
| 无标题栏 `RESIZE` + Ctrl 拖窗                              | 用户已选择一体化标题栏                                   |
| `hide_tab_bar_if_only_one_tab = true`                      | 原配置明确为 false，保留标签栏可见                       |
| 自动设置/切换代理                                          | 本机不需要，且会修改全局环境                             |
| AI CLI 自动接受参数（如 `--dangerously-skip-permissions`） | 安全风险，不默认启用                                     |
| 把 AI CLI 写进 `gui-startup`                               | 启动不可控、失败会阻塞窗口                               |
| 完整重写 Nushell `color_config`                            | 会丢失 0.116 新增颜色键                                  |
| 直接改注册表恢复经典右键菜单                               | 全局影响太大                                             |
| Third-party 主题管理器                                     | 额外依赖，Tokyo Night 直接维护即可                       |

## 4. 参考项目与借鉴点

| 项目                            | 许可            | 借鉴内容                                                                  |
| ------------------------------- | --------------- | ------------------------------------------------------------------------- |
| QianSong1/wezterm-config        | MIT             | 多文件结构、累加器、事件骨架、超链接规则                                  |
| dqtx760/wezterm-kit             | MIT             | 右键粘贴/复制、cwd 感知启动、背景图层 hsb、`cc`、c/cpp 模块、健康检查组织 |
| Byxs20/terminal_config          | 无 LICENSE 文件 | Nushell 单文件分节组织方式（未复制代码）                                  |
| nushell/nu_scripts              | MIT             | 12 组命令补全                                                             |
| starship/starship               | ISC             | 官方 tokyo-night 预设                                                     |
| Nerd Fonts                      | SIL OFL 1.1     | CaskaydiaCove Nerd Font                                                   |
| ikas-mc/ContextMenuForWindows11 | LGPL-3.0        | 可选 Windows 11 一级右键菜单（仅安装使用）                                |

详见仓库根目录 [THIRD-PARTY-NOTICES.md](../THIRD-PARTY-NOTICES.md)。

## 5. 未来可扩展方向

- 增加更多 AI CLI 包装（`cx`/`gm`/`km` 等），统一"改标签 + 启动"模式；
- 为右键菜单增加 "Open WezTerm (WSL)" 项；
- 把补全做成可选子集，减小仓库体积；
- 提供 Windows 10 的兼容说明/脚本分支；
- 增加 GitHub Actions 做 PowerShell 脚本语法检查（无需 Windows 运行环境的部分）。

## 6. 已知限制

- 主要面向 Windows 11；Windows 10 不支持新右键菜单机制；
- 右键菜单依赖开发者模式（安装时）；
- 字体/右键菜单包需要从 GitHub 下载，网络受限时需手动处理；
- 背景图来自本机，版权归原作者，随配置分享；
- 配置中的 WSL 发行版名称是示例，需要按本机修改；
- WezTerm 使用 nightly 版本验证，稳定版一般也可用，但某些配置项需要较新版本。

