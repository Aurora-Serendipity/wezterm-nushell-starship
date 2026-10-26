# 安装与升级

> 返回：[README](../README.md) · 相关：[使用手册](usage.md) · [FAQ](faq.md)

## 1. 环境要求

| 项目       | 要求                                                 |
| ---------- | ---------------------------------------------------- |
| 系统       | Windows 11（10 可用，但右键菜单集成仅 Win11）        |
| 包管理器   | `winget`（Windows 11 一般自带）                      |
| PowerShell | PowerShell 7（`pwsh`）                               |
| 权限       | 普通用户即可；安装软件时 winget 可能弹出 UAC         |
| 网络       | 能访问 GitHub（下载字体/可选右键菜单包）与 winget 源 |
| 可选       | 开发者模式（仅安装 Windows 11 一级右键菜单）         |

检查环境：

```powershell
$PSVersionTable.PSVersion      # 需要 7.x
winget --version
Get-Command wezterm, nu, starship, nvim -ErrorAction SilentlyContinue
```

## 2. 一键安装（推荐）

```powershell
git clone https://github.com/Aurora-Serendipity/wezterm-nushell-starship.git
cd wezterm-nushell-starship
pwsh -File .\scripts\install.ps1
```

安装脚本按顺序执行：

1. **依赖**：winget 安装 WezTerm / Nushell / Starship / Neovim（已安装会跳过）；
2. **字体**：下载并安装 CaskaydiaCove Nerd Font（用户级字体）；
3. **WezTerm**：备份旧目录，复制 `config/wezterm/` 到 `%USERPROFILE%\.config\wezterm\`；
4. **Starship**：备份旧文件，复制 `config/starship.toml`；
5. **Nushell**：备份旧 `config.nu` / `env.nu` / `custom-completions`，复制新文件；
6. **路径修正**：如果 `nu.exe` 不在默认位置，自动修改 WezTerm `launch.lua`；
7. **可选**：`-WithContextMenu` 安装 Windows 11 一级右键菜单；
8. **校验**：尝试加载 WezTerm / Nushell 配置并提示结果。

安装完成后关闭所有旧 WezTerm 窗口，重新打开即可。

### 2.1 安装参数

| 参数                 | 说明                                             |
| -------------------- | ------------------------------------------------ |
| `-SkipFont`          | 跳过字体下载安装（字体已装时使用）               |
| `-WithContextMenu`   | 同时安装 Windows 11 一级右键菜单（需开发者模式） |
| `-NoRestartExplorer` | 安装右键菜单后不重启资源管理器                   |
| `-DryRun`            | 只打印计划，不修改系统/文件                      |

示例：

```powershell
# 已装字体、并安装右键菜单
pwsh -File .\scripts\install.ps1 -SkipFont -WithContextMenu

# 先看看会改什么
pwsh -File .\scripts\install.ps1 -DryRun

# 只装配置、不装软件/字体（确保依赖已装）
pwsh -File .\scripts\install.ps1 -SkipFont
```

> `-DryRun` 不会下载字体、不会改文件、不会改 PATH，只输出计划。

### 2.2 安装后验证

```powershell
pwsh -File .\scripts\verify.ps1
```

预期输出 `全部通过（...）`，退出码 0。

## 3. 手动安装

不运行脚本时，按以下表格复制（先备份）：

| 源                                   | 目标                                    |
| ------------------------------------ | --------------------------------------- |
| `config/wezterm/` 全部内容           | `%USERPROFILE%\.config\wezterm\`        |
| `config/nushell/config.nu`           | `%APPDATA%\nushell\config.nu`           |
| `config/nushell/env.nu`              | `%APPDATA%\nushell\env.nu`              |
| `config/nushell/custom-completions/` | `%APPDATA%\nushell\custom-completions\` |
| `config/starship.toml`               | `%USERPROFILE%\.config\starship.toml`   |

示例：

```powershell
$src = "C:\path\to\wezterm-nushell-starship"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

# WezTerm
if (Test-Path "$HOME\.config\wezterm") { Rename-Item "$HOME\.config\wezterm" "wezterm.bak-$stamp" }
Copy-Item "$src\config\wezterm" "$HOME\.config\wezterm" -Recurse

# Starship
if (Test-Path "$HOME\.config\starship.toml") { Copy-Item "$HOME\.config\starship.toml" "$HOME\.config\starship.toml.bak-$stamp" }
Copy-Item "$src\config\starship.toml" "$HOME\.config\starship.toml" -Force

# Nushell
New-Item -ItemType Directory -Force "$env:APPDATA\nushell" | Out-Null
foreach ($f in @("config.nu","env.nu")) {
    if (Test-Path "$env:APPDATA\nushell\$f") { Copy-Item "$env:APPDATA\nushell\$f" "$env:APPDATA\nushell\$f.bak-$stamp" }
    Copy-Item "$src\config\nushell\$f" "$env:APPDATA\nushell\$f" -Force
}
if (Test-Path "$env:APPDATA\nushell\custom-completions") {
    Rename-Item "$env:APPDATA\nushell\custom-completions" "custom-completions.bak-$stamp"
}
Copy-Item "$src\config\nushell\custom-completions" "$env:APPDATA\nushell\custom-completions" -Recurse
```

最后安装 WezTerm / Nushell / Starship / Neovim 与 Nerd Font（见下文），并确保 `nu`、`wezterm` 在 PATH 中。

## 4. 字体安装

安装脚本会自动从 [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases/latest) 下载
`CaskaydiaCove.zip`，把 TTF 复制到 `%LOCALAPPDATA%\Microsoft\Windows\Fonts` 并注册用户字体。

手动安装：

1. 下载 `CaskaydiaCove.zip`；
2. 解压，选中所有 `.ttf` → 右键"安装"（或"为所有用户安装"）；
3. 重开 WezTerm。

验证：

```powershell
wezterm ls-fonts --text "❯ 󰍲 "
```

应能看到 `CaskaydiaCove Nerd Font`。如果图标显示为方块，见 [FAQ](faq.md)。

## 5. 可选组件

### 5.1 Windows 11 一级右键菜单

```powershell
# 需要开发者模式：设置 > 系统 > 开发者选项 > 开发人员模式
pwsh -File .\scripts\context-menu\install.ps1
```

安装后资源管理器空白处/文件夹右键一级菜单出现 `Open WezTerm here`。
卸载：

```powershell
pwsh -File .\scripts\context-menu\uninstall.ps1
```

详见 [scripts/context-menu/README.md](../scripts/context-menu/README.md)。

### 5.2 Neovim

安装脚本会用 winget 安装 Neovim，Nushell 中 `vim` 已别名到 `nvim`：

```powershell
nvim --version
vim            # 在 Nushell 中等价于 nvim
```

如果不需要 Neovim，可删除 `config.nu` 第 5 节的 `alias vim = nvim`。

### 5.3 Claude Code 与 `cc`

`cc` 是 Claude Code 的包装命令：先改 WezTerm 标签名为 `Claude`，再启动 `claude`。

前置：

1. 安装 Claude Code（按 Anthropic 官方方式）；
2. 确保 `claude` 与 `wezterm` 都在 PATH；
3. 在 WezTerm 内的 Nushell 中运行：

```nu
cc               # 打开 Claude Code，标签名变为 Claude
cc --version     # 参数透传
cc --resume      # 继续会话
```

不在 WezTerm 内运行 `cc` 时会跳过改标签，直接启动 `claude`。

### 5.4 WSL

配置内置 3 个 WSL 域示例：`Ubuntu-24.04`、`kali-linux`、`archlinux`。
如果你的发行版不同，需要修改三处（见 [定制指南](customization.md#wsl-发行版与启动菜单)）：

- `config/wezterm/config/launch.lua` 的启动菜单；
- `config/wezterm/config/bindings.lua` 的 `Ctrl+Shift+1/2/3`；
- `config/wezterm/config/domains.lua` 的 `wsl_domains`。

### 5.5 终端艺术工具（可选）

详见 [终端艺术玩法](terminal-art.md)。Windows 原生工具（chafa / Fastfetch / pyfiglet / sl 等）与
Ubuntu-24.04 WSL 工具（jp2a / figlet / toilet / cmatrix / cbonsai 等）的安装命令、分工和试玩示例都在该文档中。

## 6. 升级

```powershell
cd wezterm-nushell-starship
git pull
pwsh -File .\scripts\install.ps1
pwsh -File .\scripts\verify.ps1
```

安装脚本会再次备份现有配置为新的 `*.bak-<时间戳>`，不会丢失你本地的修改备份。

如果你直接修改过 `%USERPROFILE%\.config\wezterm`，升级前先把本地改动 commit/复制出来，
否则会被仓库版本覆盖（旧版本会保留在 `.bak-时间戳` 中）。

## 7. 回滚与卸载

### 7.1 回滚配置

安装脚本把被覆盖的内容重命名为 `*.bak-<时间戳>`，例如：

```
C:\Users\<你>\.config\wezterm.bak-20261025-224500
C:\Users\<你>\.config\starship.toml.bak-20261025-224500
C:\Users\<你>\AppData\Roaming\nushell\config.nu.bak-20261025-224500
```

手动回滚：

1. 删除/改名当前配置；
2. 把备份改回原名；
3. 重启 WezTerm / 新开 Nushell。

### 7.2 卸载右键菜单

```powershell
pwsh -File .\scripts\context-menu\uninstall.ps1
```

经典入口（"显示更多选项"）仍然可用。

### 7.3 卸载配置

删除以下内容即可（建议先备份）：

- `%USERPROFILE%\.config\wezterm\`
- `%USERPROFILE%\.config\starship.toml`
- `%APPDATA%\nushell\config.nu`、`env.nu`、`custom-completions\`
- `%APPDATA%\nushell\vendor\autoload\starship.nu`（生成文件，可删）

## 8. 网络受限时

- `install.ps1` 下载字体带 3 次重试 + `curl` 回退；失败只会跳过字体，不影响其它配置；
- `scripts/context-menu/install.ps1` 同样有重试，还支持 `-PackageDir <已解压目录>` 离线安装；
- winget 安装失败时，可以手动安装对应软件后重新运行脚本（脚本会跳过已安装项）。

## 9. 安装后的目录样例

```
%USERPROFILE%\
├─ .config\
│  ├─ wezterm\                 ← WezTerm 配置（本仓库 config/wezterm）
│  └─ starship.toml            ← Starship 配置
└─ AppData\Roaming\nushell\
   ├─ config.nu                ← 7 节配置
   ├─ env.nu
   ├─ custom-completions\      ← 12 组补全
   └─ vendor\autoload\starship.nu  ← 每次启动自动生成
```

## 10. 相关文档

- [使用手册](usage.md)
- [常见问题](faq.md)
- [排错手册](troubleshooting.md)

