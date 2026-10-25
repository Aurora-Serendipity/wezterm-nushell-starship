# 排错手册

> 返回：[README](../README.md) · 相关：[FAQ](faq.md) · [安装](installation.md)

## 0. 排查总原则

1. **先备份**：任何修改前保留当前配置/备份；
2. **分层定位**：WezTerm（外壳）、Nushell（shell）、Starship（提示符）、字体、右键菜单，逐层排查；
3. **看日志**：WezTerm 用 `Ctrl+Shift+L`/`F12` 调试面板；
4. **用命令验证**：不要只靠肉眼；
5. **最小化变更**：一次只改一处，改完立即验证。

## 1. 一键收集信息

```powershell
# 版本
wezterm --version
nu --version
starship --version
nvim --version

# 配置是否存在
Test-Path "$HOME\.config\wezterm\wezterm.lua"
Test-Path "$env:APPDATA\nushell\config.nu"
Test-Path "$HOME\.config\starship.toml"

# 健康检查
pwsh -File .\scripts\verify.ps1
```

## 2. WezTerm 层

### 2.1 配置报错/无法启动

```powershell
wezterm --config-file "$HOME\.config\wezterm\wezterm.lua" show-keys
```

- 输出中出现 `ERROR` / `WARN` 即为配置问题；
- 常见原因：Lua 语法错误、模块路径错误、`require` 名称拼错；
- 修复后按 `Ctrl+Shift+Alt+R` 重载。

### 2.2 改了配置不生效

| 修改位置                        | 生效方式                              |
| ------------------------------- | ------------------------------------- |
| `wezterm.lua` 入口              | 自动热重载                            |
| `config/`、`events/`、`colors/` | 保存后若不生效，按 `Ctrl+Shift+Alt+R` |
| 子模块深层变化                  | 关闭所有窗口后重开                    |

### 2.3 窗口/标签/窗格行为异常

- 检查 `config/appearance.lua` 的窗口参数；
- 检查 `config/bindings.lua` 是否有键位冲突（`show-keys` 可看最终绑定）；
- 窗口位置问题看 `events/window-position.lua`。

### 2.4 字体/图标异常

```powershell
wezterm ls-fonts --text "❯ 󰍲  "
```

- 输出里应有 `CaskaydiaCove`；
- 没有 → 字体未安装/未注册；
- 有但仍显示方块 → 换一个 Nerd Font 测试，或检查是否只安装了部分字重。

### 2.5 背景图不显示

- 确认 `config/wezterm/backdrops/flower-meadow.jpg` 存在；
- 检查 `appearance.lua` 中的 `File` 路径；
- 背景图是可选效果，缺失不会影响终端使用。

## 3. Nushell 层

### 3.1 `nu` 启动报错

```powershell
nu --config "$env:APPDATA\nushell\config.nu" -c 'print "ok"'
```

- 有语法错误会直接打印行号；
- 常见：补全文件路径错误、`use`/`source` 混用、Nu 版本不兼容。

### 3.2 Starship 不显示

```powershell
Get-Command starship
Test-Path "$env:APPDATA\nushell\vendor\autoload\starship.nu"
```

- 重新生成：在 Nushell 中执行 `starship init nu | save -f ...`；
- 或删除 `vendor/autoload/starship.nu` 后新开 Nushell（配置第 2 节会自动重建）。

### 3.3 补全不生效

- 检查文件是否存在；
- `mvn` 必须 `source`；
- `cargo` 只提供子命令补全（`cargo build` 等），根命令 `cargo` 不注册是正常的；
- 新开 Nushell 再试。

### 3.4 `cc` 异常

- 不在 WezTerm 内：不会改标签，直接启动 `claude`；
- 提示 `wezterm cli` 失败：`wezterm` 不在 PATH，或当前不在 WezTerm 会话；
- 提示 `claude` 找不到：安装 Claude Code 并重开终端。

## 4. Starship 层

### 4.1 提示符为空

```powershell
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
starship prompt
```

- 报 TOML 语法错误 → 按提示修;
- 无输出 → 检查 `format` 是否为空。

### 4.2 图标/分隔符乱码

- 字体问题（见 2.4）；
- 终端编码问题：WezTerm 默认 UTF-8，一般无需改。

### 4.3 Git 状态显示慢

- 在超大仓库中 Starship 的 git 状态较慢；
- 可临时禁用 `[git_status]` 或减少模块；
- 不影响终端本身。

## 5. Windows 11 右键菜单层

### 5.1 菜单项没出现

```powershell
Get-AppxPackage | Where-Object { $_.InstallLocation -like '*ContextMenuCustomDev*' }
```

- 没包 → 运行 `scripts/context-menu/install.ps1`；
- 有包但没菜单 → 重启资源管理器；还不行重跑安装脚本；
- 检查开发者模式是否开启。

### 5.2 点击菜单项没反应

- 检查配置 JSON：

```powershell
$pkg = Get-AppxPackage | Where-Object { $_.InstallLocation -like '*ContextMenuCustomDev*' }
$cfg = Join-Path $env:LOCALAPPDATA "Packages\$($pkg.PackageFamilyName)\LocalState\custom_commands\Open WezTerm here.json"
Get-Content $cfg
```

- 确认 `exe` 路径正确（`wezterm-gui.exe` 是否存在）；
- 修改后重启资源管理器。

### 5.3 想彻底移除右键菜单

```powershell
pwsh -File .\scripts\context-menu\uninstall.ps1
```

经典入口不受影响。

## 6. 安装/网络问题

### 6.1 GitHub 下载失败

- 字体或右键菜单包下载被重置；
- 重试安装脚本（有 3 次重试 + curl 回退）；
- 右键菜单支持 `-PackageDir` 离线安装；
- 字体可手动下载 `CaskaydiaCove.zip` 安装。

### 6.2 winget 安装失败

- 确认 `winget --version`；
- 手动安装对应软件后重跑脚本；
- 企业网络可能拦截 winget 源。

### 6.3 安装后 `nu`/`wezterm` 仍找不到

- 新开终端让 PATH 生效；
- 检查用户 PATH：

```powershell
$env:PATH -split ';' | Select-String -Pattern 'WezTerm|nu|starship|Neovim'
```

## 7. 性能问题

| 现象       | 可能原因          | 处理                      |
| ---------- | ----------------- | ------------------------- |
| 启动慢     | 后台任务/插件     | 关闭不必要的标签/窗格     |
| 提示符慢   | Git 状态/语言版本 | 精简 Starship 模块        |
| 字体渲染卡 | 透明背景 + 大图   | 降低背景图分辨率/关闭 hsb |
| 内存高     | 回滚缓冲 5000 行  | 调小 `scrollback_lines`   |

## 8. 回滚检查清单

- [ ] 备份目录/文件存在（`*.bak-<时间戳>`）
- [ ] 恢复后新开 WezTerm
- [ ] 新开 Nushell
- [ ] `pwsh -File .\scripts\verify.ps1` 通过
- [ ] 右键菜单如不需要，已 `uninstall.ps1`

## 9. 仍无法解决

请提供：

- Windows 版本（`winver`）；
- WezTerm / Nushell / Starship 版本；
- `verify.ps1` 输出；
- `wezterm --config-file ... show-keys` 中的 ERROR/WARN；
- 相关配置片段（注意脱敏路径/密钥）。

到仓库 Issues 提问时请附上以上信息。
