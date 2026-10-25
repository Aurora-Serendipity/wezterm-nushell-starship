# 常见问题 FAQ

> 返回：[README](../README.md) · 相关：[排错手册](troubleshooting.md)

## 安装与生效

### Q1：安装后界面没变化？

关闭所有旧 WezTerm 窗口，重新打开。WezTerm 的配置在进程启动时加载，已经打开的窗口不会自动应用全部新配置。
Nushell 配置需要新开标签/窗口；Starship 在下一行提示符生效。

### Q2：`pwsh -File .\scripts\install.ps1` 报 winget 安装失败？

- 先确认 `winget --version` 正常；
- 某些包需要 UAC，请在弹窗中确认；
- 也可以手动安装 WezTerm/Nushell/Starship/Neovim 后重新运行脚本（脚本会跳过已安装项）；
- 企业网络可能限制 winget 源，见 [安装文档](installation.md#8-网络受限时)。

### Q3：安装脚本会覆盖我原来的配置吗？

会先备份为 `*.bak-<时间戳>`（例如 `.config\wezterm.bak-20261025-224500`），然后才复制新配置。
如果是 Git 仓库方式维护的配置，也建议先 commit。

### Q4：如何完全恢复我原来的配置？

把 `*.bak-<时间戳>` 改回原名，重启 WezTerm；Nushell 新开窗口。详见 [回滚](installation.md#71-回滚配置)。

## WezTerm

### Q5：字体图标显示为方块/问号？

- 确认已安装 **CaskaydiaCove Nerd Font**；
- 运行 `wezterm ls-fonts --text "❯ 󰍲 "`，看是否解析到 `CaskaydiaCove`；
- 字体安装后需要重启 WezTerm；
- 如果只装了 Nerd Font 的某些字重，确保 Regular 已装。

### Q6：标签标题为什么显示 `>_nu` / 某个命令名？

标签标题逻辑：手动设置的静态标题优先（铅笔图标），否则显示当前前台进程名，并带序号。
运行命令时显示对应进程是正常行为；按 `Ctrl+Shift+R` 可以手动命名。

### Q7：为什么启动窗口不是全屏/不是固定大小？

设计如此：启动时占活动屏幕 50%，居中。想改全屏/尺寸，修改
`config/wezterm/events/window-position.lua` 与 `config/appearance.lua` 的 `initial_cols/rows`。

### Q8：背景图可以换成自己的吗？

可以。仓库内 `backdrops/flower-meadow.jpg` 是本机使用的背景图（版权归原作者）；
直接用同名文件替换成你的壁纸即可；详见 [定制](customization.md#2-背景图透明度与亮度)。

### Q9：右键粘贴不生效/和别的软件冲突？

配置中右键 = 粘贴、`Shift`+右键 = 复制；这是 WezTerm 绑定，只影响终端窗口。
如果鼠标软件（如手势工具）占用了右键，需要在鼠标软件里放行。

### Q10：`Ctrl+Shift+R` 不是重载配置吗？

WezTerm 默认 `Ctrl+Shift+R` 是重载配置；本方案把它改成**重命名标签页**，重载配置移到
`Ctrl+Shift+Alt+R`。这是有意为之，避免与常用操作冲突。

## Nushell

### Q11：打开 WezTerm 提示找不到 `nu.exe`？

- 确认 Nushell 已安装：`nu --version`；
- 本方案默认使用 `%LOCALAPPDATA%\Programs\nu\bin\nu.exe`；
- 如果安装在别处，`scripts/install.ps1` 会尝试修正；也可以手动改 `config/wezterm/config/launch.lua`。

### Q12：Starship 提示符没出现/提示符很朴素？

- 检查 `starship --version`；
- 检查 `%APPDATA%\nushell\vendor\autoload\starship.nu` 是否存在；
- 在 Nushell 中执行 `starship init nu` 看是否有报错；
- 确认 `config.nu` 第 2 节没有被改动。

### Q13：右侧时间没显示，或显示在错误的位置？

- 确认 Starship `right_format = "$time"`；
- 确认 Nushell `$env.config.render_right_prompt_on_last_line = true`；
- 终端窗口宽度太窄时，右侧提示符可能被压缩，拉宽窗口试试。

### Q14：补全不生效？

- 确认 `%APPDATA%\nushell\custom-completions\` 下有对应文件；
- `mvn` 需要用 `source` 而不是 `use *`；
- 新开 Nushell 后再试；
- 运行 `pwsh -File .\scripts\verify.ps1` 检查补全数量。

### Q15：`vim` 命令不存在？

`alias vim = nvim` 依赖 Neovim 安装。安装 `nvim` 后新开 Nushell；或删除该别名。

### Q16：`cc` 提示找不到 `claude` / `wezterm`？

- `cc` 需要 Claude Code 与 `wezterm` 在 PATH；
- 在 WezTerm 内运行时才会改标签名；其它终端直接运行 `claude`；
- 安装 `claude` 后新开窗口让 PATH 生效。

### Q17：为什么 `cc --version` 能透传参数？

`cc` 使用 `def --wrapped`，未知参数会原样传给 `claude`；这也是 Nushell 自定义命令透传外部参数的标准写法。

## Windows 11 右键菜单

### Q18：右键菜单里没有 `Open WezTerm here`？

- 确认已运行 `scripts/context-menu/install.ps1`；
- 需要 **Windows 11** + **开发者模式**；
- 安装后需要资源管理器重启（脚本会自动重启）；
- 若仍不显示，重新运行安装脚本，或注销/重启。

### Q19：安装右键菜单时提示需要开发者模式？

设置 → 系统 → 开发者选项 → 打开"开发人员模式"，然后重试。

### Q20：Store 版本的 Custom Context Menu 装不上（0x803f8001）？

这是 Microsoft Store 账号/区域限制。本方案使用 GitHub Release 的 DEV 包做用户级松散注册，
不需要 Store、不需要管理员。详见 [scripts/context-menu](../scripts/context-menu/README.md)。

### Q21：`Open WezTerm here` 出现在"显示更多选项"里而不是一级菜单？

说明当前只有 WezTerm 安装器写入的经典注册表项，没有装可选的一级菜单扩展。
运行 `scripts/context-menu/install.ps1` 即可；旧入口会保留作为回退。

### Q22：不想用第三方右键菜单扩展怎么办？

不安装即可；经典入口仍然可以在"显示更多选项"里使用。
也可以运行 `scripts/context-menu/uninstall.ps1` 卸载，不影响 WezTerm 本身。

## 性能与其它

### Q23：提示符显示变慢？

Starship 会执行 Git 状态、语言版本等命令。可以在 `starship.toml` 里删除不需要的模块，
或调整 `cmd_duration.min_time`。大型仓库中 Git 状态本身较慢，属正常现象。

### Q24：`wezterm` 不在 PATH，`cc` 改不了标签名？

把 WezTerm 安装目录加入用户 PATH（安装脚本会尝试），或重新打开终端；验证：

```powershell
Get-Command wezterm
```

### Q25：配置改坏了怎么快速恢复？

- WezTerm：`Ctrl+Shift+Alt+R` 重载；还不行就恢复备份；
- Nushell：新开窗口；恢复 `config.nu.bak-*`；
- 全量：重新运行安装脚本（会再次备份当前配置），或 `git checkout` 仓库配置后重装。

### Q26：这个配置支持 Windows 10 / macOS / Linux 吗？

主要面向 Windows 11。WezTerm/Nushell/Starship 本身跨平台，但：

- Windows 10 没有新右键菜单机制（经典入口仍可用）；
- 路径、WSL、字体安装脚本按 Windows 编写；
- macOS/Linux 需要自行调整路径与启动项。

## 还没有解决？

看 [排错手册](troubleshooting.md)，或运行：

```powershell
pwsh -File .\scripts\verify.ps1
```

