# v1.0.0 — Windows 11 终端配置（WezTerm + Nushell + Starship）

首个公开版本：本机实际使用、经过完整验证的终端配置方案。

## 亮点

- WezTerm 模块化配置（入口 + config/ + events/ + colors/ + utils/），Tokyo Night Moon 外观
- Nushell 0.116 单文件 7 节配置 + 12 组命令补全 + `vim=nvim` + `cc`（Claude Code 包装）
- Starship Powerline 提示符：目录/Git/多语言/耗时/任务数 + 右侧时间
- 文件夹空白处与文件夹上的 Windows 11 一级右键菜单 “Open WezTerm here”（可选）
- 一键安装脚本（winget + 字体 + 自动备份）与健康检查脚本
- 完整中文技术文档（安装/使用/组件/定制/FAQ/排错/设计/变更）

## 安装

```powershell
git clone https://github.com/Aurora-Serendipity/wezterm-nushell-starship.git
cd wezterm-nushell-starship
pwsh -File .\scripts\install.ps1
pwsh -File .\scripts\verify.ps1
```

## Release 附件

- `install.ps1` / `verify.ps1`：安装与健康检查
- `install-context-menu.ps1` / `uninstall-context-menu.ps1`：可选 Windows 11 一级右键菜单
- `wezterm-window.png` / `context-menu.png`：效果截图

## 校验和（SHA256）

| 文件 | 大小 | SHA256 |
| --- | --- | --- |
| context-menu.png | 1461.5 KB | `470E8B340F2DC6DF8931F0D394271FADADEF47A62EC23BFE939C85456BD2506E` |
| install-context-menu.ps1 | 7.5 KB | `9F21C5D53EDBBBC79FF240CFEA1D152798EC7DBB96551522239139EEEF4EF8EC` |
| install.ps1 | 13.6 KB | `744B9735CA1793DFAD7CA8940231FE46E4DC0F93FAC8DC895F8DE03D6F103F97` |
| uninstall-context-menu.ps1 | 1.7 KB | `06A4CC0A6CFCBA1EAC954B82E188F024273654F013DC43CEDE6AFDDBA8838588` |
| verify.ps1 | 9.5 KB | `16D9459B0D19F3749192023068DA60C29F0B201D1D53D26C4F757D2009C42A2B` |
| wezterm-window.png | 1614.7 KB | `9E284EE4A122278C3BC7929AEBD711B846CE0D14B87678DEA180B629F5CBBCB7` |

## 环境基线

Windows 11 26H2 · WezTerm nightly `20261010-083911-e2a98e1b` · Nushell `0.116.1` · Starship `1.27.0` ·
CaskaydiaCove Nerd Font（v3）· 可选 Neovim 0.12.6 / Claude Code 2.1.310

## 文档

完整文档：https://github.com/Aurora-Serendipity/wezterm-nushell-starship/tree/main/docs

## 许可

MIT License（代码与配置）；第三方来源见 [THIRD-PARTY-NOTICES.md](../THIRD-PARTY-NOTICES.md)。
背景图版权归原作者，仅随本配置分享，不计入 MIT 许可范围。
