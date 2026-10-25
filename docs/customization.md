# 定制指南

> 返回：[README](../README.md) · 相关：[组件详解](components.md) · [使用手册](usage.md)

## 1. 修改主题与配色

### 1.1 换内置配色

编辑 `config/wezterm/config/appearance.lua`：

```lua
color_scheme = "Tokyo Night Moon",
```

查看可用配色：

```powershell
wezterm ls-fonts --list-system
wezterm show-keys   # 仅示例
```

内置配色列表：`wezterm` 文档中的 "Color schemes"，或运行：

```powershell
wezterm --config-file NUL show-keys 2>$null
```

（更简单的方式：在 `wezterm` 配置里用 `wezterm.color.get_builtin_schemes()` 列出。）

### 1.2 覆盖界面元素

编辑 `config/wezterm/colors/custom.lua`，例如改活动标签颜色：

```lua
tab_bar = {
  active_tab = { bg_color = "#82aaff", fg_color = "#1e2030" },
  -- ...
}
```

## 2. 背景图、透明度与亮度

编辑 `config/wezterm/config/appearance.lua`：

```lua
window_background_opacity = 0.7,
background = {
  {
    source = { File = wezterm.config_dir .. "/backdrops/flower-meadow.jpg" },
    horizontal_align = "Center",
    vertical_align = "Middle",
    repeat_x = "NoRepeat",
    repeat_y = "NoRepeat",
    hsb = { brightness = 0.9, saturation = 1.0, hue = 1.0 },
  },
},
```

- **换壁纸**：把图片命名为 `flower-meadow.jpg` 放进 `config/wezterm/backdrops/`，或改 `File` 路径；
- **更亮/更暗**：只改 `hsb.brightness`（0–1）；
- **整体更透明**：改 `window_background_opacity`；
- 修改完成后 WezTerm 会自动重载或按 `Ctrl+Shift+Alt+R`。

## 3. 字体

编辑 `config/wezterm/config/fonts.lua`：

```lua
return {
  font = wezterm.font("CaskaydiaCove Nerd Font"),
  font_size = 13,
}
```

换成其它 Nerd Font（确保已安装）：

```lua
font = wezterm.font("JetBrainsMono Nerd Font"),
```

字号临时调整：`Leader f` 后 `k/j` 放大/缩小、`r` 重置。

## 4. 窗口与标签栏

编辑 `config/wezterm/config/appearance.lua`：

| 配置                            | 默认值                       | 说明               |
| ------------------------------- | ---------------------------- | ------------------ |
| `window_decorations`            | `INTEGRATED_BUTTONS\|RESIZE` | 一体化细标题栏     |
| `initial_cols` / `initial_rows` | 130 / 50                     | 初始尺寸           |
| `window_padding`                | 6                            | 内边距             |
| `use_fancy_tab_bar`             | false                        | retro 标签栏       |
| `show_tab_index_in_tab_bar`     | true                         | 显示序号           |
| `hide_tab_bar_if_only_one_tab`  | false                        | 单标签也显示标签栏 |
| `tab_max_width`                 | 25                           | 标签最大宽度       |
| `enable_scroll_bar`             | true                         | 滚动条             |
| `default_cursor_style`          | `BlinkingBlock`              | 光标样式           |

窗口启动尺寸/位置：`config/wezterm/events/window-position.lua`（50% 活动屏居中）。

## 5. 键位

编辑 `config/wezterm/config/bindings.lua`。

### 5.1 新增一条键位

```lua
{ key = "F5", mods = "NONE", action = act.ReloadConfiguration },
```

### 5.2 修改 leader

```lua
leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
```

> 不建议把 leader 改成 Alt：Windows 上 Alt 常与输入法/菜单快捷键冲突。

### 5.3 修改键位后验证

```powershell
wezterm --config-file "$HOME\.config\wezterm\wezterm.lua" show-keys
```

## 6. 启动菜单与默认 shell

编辑 `config/wezterm/config/launch.lua`：

```lua
default_prog = { "C:\\path\\to\\nu.exe" },
launch_menu = {
  { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } },
  -- ...
},
```

如果 Nushell 安装在非默认位置，可直接写绝对路径。安装脚本也会在复制后自动修正默认路径。

## 7. WSL 发行版与启动菜单

如果你的 WSL 发行版不是 `Ubuntu-24.04` / `kali-linux` / `archlinux`，改三处：

1. `config/wezterm/config/launch.lua` 的 3 个 `wsl -d ...`；
2. `config/wezterm/config/bindings.lua` 的 `Ctrl+Shift+1/2/3`；
3. `config/wezterm/config/domains.lua` 的 `wsl_domains`。

查看本机发行版：

```powershell
wsl -l -q
```

## 8. Nushell 配置

编辑 `%APPDATA%\nushell\config.nu`（仓库源：`config/nushell/config.nu`）。

### 8.1 提示符

由第 2 节生成 Starship autoload；不要改成自定义 `PROMPT_COMMAND`，否则会覆盖 Starship。

### 8.2 右侧提示符

```nu
$env.config.render_right_prompt_on_last_line = true
```

配合 Starship 的 `right_format = "$time"` 生效。

### 8.3 补全

- 新增补全：把 `.nu` 文件放进 `%APPDATA%\nushell\custom-completions\<tool>\`；
- 在 `config.nu` 第 4 节加一行 `use ...`（未导出 extern 的文件用 `source`）；
- 新开 Nushell 验证。

### 8.4 别名与 AI CLI

第 5 节：

```nu
alias vim = nvim

def --wrapped cc [...args: string] {
    if ((($env.WEZTERM_PANE? | default "") | is-empty) == false) {
        wezterm cli set-tab-title "Claude"
    }
    claude ...$args
}
```

可以仿照 `cc` 添加自己的包装，例如 `codex`：

```nu
def --wrapped cx [...args: string] {
    if ((($env.WEZTERM_PANE? | default "") | is-empty) == false) {
        wezterm cli set-tab-title "Codex"
    }
    codex ...$args
}
```

## 9. Starship 提示符

编辑 `~/.config/starship.toml`（仓库源：`config/starship.toml`）。

### 9.1 增加语言模块

在 `format` 中加入变量，并新增对应段：

```toml
format = """
...
$dotnet\
...
"""

[dotnet]
symbol = ""
style = "bg:#212736"
format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'
```

### 9.2 关掉某个模块

从 `format` 中删除对应 `$变量` 即可。

### 9.3 修改右侧时间

```toml
right_format = "$time"

[time]
time_format = "%R"   # HH:MM
```

改成 24 小时制 `%H:%M`、带秒 `%H:%M:%S` 都可以。

### 9.4 验证

```powershell
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
starship prompt
starship prompt --right
```

## 10. Windows 11 右键菜单

菜单配置文件：

```
%LOCALAPPDATA%\Packages\<包族名>\LocalState\custom_commands\Open WezTerm here.json
```

修改后重启资源管理器：

```powershell
Stop-Process -Name explorer -Force
Start-Process explorer
```

想增加"以 WSL 打开"等菜单项：在同一目录新增 JSON 即可（多个命令会合并进子菜单）。
具体字段参考 [scripts/context-menu](../scripts/context-menu/README.md)。

## 11. 修改后验证

```powershell
pwsh -File .\scripts\verify.ps1
```

- WezTerm 配置加载：`wezterm --config-file ... show-keys` 无 ERROR/WARN；
- Nushell：`nu --config ... -c 'print ok'`；
- Starship：`starship prompt`。

## 12. 注意

- 修改 `config/` 子模块后，WezTerm 可能不会立即热重载：按 `Ctrl+Shift+Alt+R`；
- 修改 `config.nu` 后需要新开 Nushell；
- 修改 Starship TOML 后下一条提示符生效；
- 修改右键菜单 JSON 后需要重启资源管理器；
- 所有改动建议先在仓库工作区修改，再运行安装脚本，方便 git 追踪。
