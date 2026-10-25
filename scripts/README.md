# 脚本说明

| 脚本                         | 用途                                                      |
| ---------------------------- | --------------------------------------------------------- |
| `install.ps1`                | 一键安装/备份配置、安装依赖与字体、可选右键菜单、基础校验 |
| `verify.ps1`                 | 健康检查（20+ 项）                                        |
| `context-menu/install.ps1`   | 可选：Windows 11 一级右键菜单                             |
| `context-menu/uninstall.ps1` | 卸载右键菜单                                              |

## install.ps1

```powershell
pwsh -File .\scripts\install.ps1
pwsh -File .\scripts\install.ps1 -SkipFont
pwsh -File .\scripts\install.ps1 -WithContextMenu
pwsh -File .\scripts\install.ps1 -DryRun
```

| 参数                 | 说明                               |
| -------------------- | ---------------------------------- |
| `-SkipFont`          | 跳过字体下载（字体已装时）         |
| `-WithContextMenu`   | 同时安装右键菜单（需要开发者模式） |
| `-NoRestartExplorer` | 安装右键菜单后不重启资源管理器     |
| `-DryRun`            | 只打印计划，不修改系统             |

安装行为：

1. 检查 Windows 与 winget；
2. 安装/检查 WezTerm、Nushell、Starship、Neovim；
3. 安装字体（或跳过）；
4. 备份现有配置（`*.bak-<时间戳>`）；
5. 复制三份配置；
6. 修正 WezTerm 中的 Nu 路径；
7. 可选安装右键菜单；
8. 基础校验。

## verify.ps1

```powershell
pwsh -File .\scripts\verify.ps1
```

退出码 0 = 全部通过，1 = 有失败项。检查范围：

- 软件版本；
- 字体文件与 WezTerm 字体解析；
- 三份配置存在与加载；
- WezTerm leader/键位；
- Nushell native-clip、right prompt、`cc`、补全；
- Starship 左/右提示符、autoload、c/cpp；
- PATH 与可选右键菜单。

## context-menu

```powershell
# 安装（自动探测 wezterm-gui.exe）
pwsh -File .\scripts\context-menu\install.ps1

# 指定路径 / 离线包
pwsh -File .\scripts\context-menu\install.ps1 -WezTermGuiPath "C:\Program Files\WezTerm\wezterm-gui.exe"
pwsh -File .\scripts\context-menu\install.ps1 -PackageDir "C:\path\to\extracted\DEV\package"

# 卸载
pwsh -File .\scripts\context-menu\uninstall.ps1
```

- 需要 Windows 11 + 开发者模式；
- 使用 LGPL-3.0 的 Custom Context Menu 开发者包，用户级安装，无需管理员；
- 经典右键入口保留在"显示更多选项"中。

## 安全说明

- 所有覆盖操作前自动备份；
- 不修改系统级 PowerShell Profile；
- 不自动设置代理；
- 默认不安装右键菜单（需显式 `-WithContextMenu` 或单独运行脚本）；
- 字体/右键菜单包均从官方 Release 下载。

