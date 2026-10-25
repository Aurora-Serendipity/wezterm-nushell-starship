# 安装 / 修复 Windows 11 一级右键菜单项 "Open WezTerm here"

本目录脚本提供**可选**的 Windows 11 右键菜单集成：

- 把 `Open WezTerm here` 提升到 Windows 11 **新右键菜单的一级**
  （文件夹空白处与文件夹上均可用），不需要再点"显示更多选项"。
- 原理：使用 LGPL-3.0 开源工具 **Custom Context Menu**
  （[ikas-mc/ContextMenuForWindows11](https://github.com/ikas-mc/ContextMenuForWindows11)）
  的开发者包做用户级松散注册；Windows 11 新菜单只接受带包身份、实现 `IExplorerCommand` 的扩展，
  经典注册表项无法直接"提升"。
- 该功能需要**开发者模式**（Windows 设置 > 系统 > 开发者选项 > 开发人员模式）。
- 旧经典入口（"显示更多选项"里的 `Open WezTerm here`）不会被删除，可作为回退。

## 用法

```powershell
# 安装/修复（自动探测 wezterm-gui.exe 路径）
pwsh -File .\install.ps1

# 指定 WezTerm 路径 / 离线包目录
pwsh -File .\install.ps1 -WezTermGuiPath "C:\Program Files\WezTerm\wezterm-gui.exe"
pwsh -File .\install.ps1 -PackageDir "C:\path\to\extracted\DEV\package"

# 卸载（恢复为只有"显示更多选项"里的经典入口）
pwsh -File .\uninstall.ps1
```

安装完成后会自动重启资源管理器；若菜单未出现，注销/重启或重新运行脚本。

## 注意

- 该工具为 **LGPL-3.0** 许可；本项目只是安装并使用其发布包，不复制、修改或再分发其源代码。
- 使用的是未签名 DEV 包（用户级、无需管理员）。如果你不接受第三方 shell 扩展，
  可以跳过本目录，继续使用"显示更多选项"中的经典入口。
- 固定使用上游 `5.9.0.2` Release 中的 DEV 包（包版本 `5.9.0.53`）。
