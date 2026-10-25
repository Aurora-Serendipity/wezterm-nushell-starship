# 第三方代码与许可声明（THIRD-PARTY NOTICES）

本仓库的配置在组织方式、少量片段与思路上参考/改编自以下开源项目。
除特别说明外，这里列出的项目**不随本仓库分发**，仅在运行时使用或提供设计参考。

## 配置结构参考

### QianSong1/wezterm-config

- 项目：https://github.com/QianSong1/wezterm-config
- 上游：https://github.com/KevinSilvester/wezterm-config
- 许可：MIT License，Copyright (c) 2023 Kevin Silvester
- 参考内容：WezTerm 多文件目录结构、`Config:init()/append()` 配置累加器思路、
  事件模块骨架（tab-title / right-status / new-tab-button）、超链接规则与键位组织方式。
  本仓库在原方案基础上做了 Windows 环境、Tokyo Night Moon、中文注释等适配。

### dqtx760/wezterm-kit

- 项目：https://github.com/dqtx760/wezterm-kit
- 许可：MIT License，Copyright (c) 2026 DQTX
- 参考内容：鼠标右键粘贴 / Shift+右键复制、`gui-startup` 的 cwd 感知与居中处理、
  背景图层对齐/hsb 思路、Nushell AI CLI 包装（`cc`）、Starship `c`/`cpp` 模块组织、
  健康检查项的组织方式。

### Byxs20/terminal_config

- 项目：https://github.com/Byxs20/terminal_config
- 说明：Nushell 单文件、按功能分节的组织方式参考了该项目；
  上游仓库未附 LICENSE 文件，本仓库**未直接复制其代码**，只借鉴了组织思路。

## 补全脚本

### nushell/nu_scripts

- 项目：https://github.com/nushell/nu_scripts
- 许可：MIT License
- 参考内容：`config/nushell/custom-completions/` 下的 12 个补全脚本取自该仓库的
  `custom-completions/`，详见 [该目录 README](config/nushell/custom-completions/README.md)。

## Starship

### starship/starship

- 项目：https://github.com/starship/starship
- 许可：ISC License
- 参考内容：`config/starship.toml` 以官方 `tokyo-night` 预设为基础，并按本机偏好增强。
  预设文件属于 Starship 项目（ISC）。

配置中还参考了以下公开配置的配色/模块组织思路：

- KnightChaser/starship-tokyonight-neo
- CoryCharlton/starship-configuration
- ansidev/starship-primer
- catppuccin/starship
- fang2hou/starship-gruvbox-rainbow

## 字体

- 项目：Nerd Fonts（https://github.com/ryanoasis/nerd-fonts）
- 字体：CaskaydiaCove Nerd Font（基于 Microsoft Cascadia Code，SIL Open Font License 1.1）
- 说明：字体**不随本仓库分发**；安装脚本会从 Nerd Fonts Release 下载安装。
  字体的授权与再分发请遵循 SIL OFL 1.1。

## 可选：Windows 11 右键菜单

### ikas-mc/ContextMenuForWindows11（Custom Context Menu）

- 项目：https://github.com/ikas-mc/ContextMenuForWindows11
- 许可：GNU Lesser General Public License v3.0（LGPL-3.0）
- 说明：仅通过其官方 Release 的开发者包安装 Windows 11 一级右键菜单扩展，
  **本仓库不包含其源代码或二进制**，也未修改/再分发。安装/卸载脚本见
  [scripts/context-menu](scripts/context-menu/README.md)。

## 运行时软件（本仓库不分发）

| 软件                | 许可                              |
| ------------------- | --------------------------------- |
| WezTerm             | MIT                               |
| Nushell             | MIT                               |
| Starship            | ISC                               |
| Neovim              | Apache-2.0 / Vim license          |
| Claude Code（可选） | 由 Anthropic 提供，遵循其许可协议 |

## 背景图

仓库中的 `config/wezterm/backdrops/flower-meadow.jpg` 是本机使用的背景图，
随本配置一起分享，仅用于展示用途。图片版权归原作者所有，**不计入本仓库 MIT 许可范围**；
如涉及版权问题，请替换或删除该文件（保持同名即可）。

`docs/images/*.png` 截图与仓库内背景图一致，使用的是同一张图片。

