# 第三方代码与许可声明（THIRD-PARTY NOTICES）

本项目（`~/.config/wezterm`）的目录组织方式与部分实现参考/改编自以下开源项目：

## wezterm-config

- 项目：https://github.com/QianSong1/wezterm-config
- 上游：https://github.com/KevinSilvester/wezterm-config
- 许可：MIT License，Copyright (c) 2023 Kevin Silvester

改编内容包括但不限于：多文件目录结构、`Config:init()/append()` 配置累加器思路、
`events/tab-title.lua`、`events/right-status.lua`、`events/new-tab-button.lua` 的
实现骨架，以及 `hyperlink_rules`、启动菜单、键位表的组织方式。
以上内容已针对本机环境（Windows 11、WezTerm nightly、CaskaydiaCove Nerd Font、
Tokyo Night Moon 配色、retro 标签栏）做适配与修改。

## wezterm-kit

- 项目：https://github.com/dqtx760/wezterm-kit
- 许可：MIT License，Copyright (c) 2026 DQTX

借鉴内容（均为小幅配置片段/思路，已按本机环境改写）：

- 鼠标绑定：右键粘贴 / Shift+右键复制
- `gui-startup` 的 cwd 感知与置中处理
- 背景图层（对齐 / hsb）增强思路
- Nushell 的 AI CLI 标签页改名包装（`cc`）
- Starship 的 `c` / `cpp` 模块组织
- 健康检查脚本的检查项组织方式（本仓库 `scripts/verify.ps1`）

MIT License 文本同上，版权行以本节 Copyright 为准。

### MIT License 原文

```
MIT License

Copyright (c) 2023 Kevin Silvester

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
