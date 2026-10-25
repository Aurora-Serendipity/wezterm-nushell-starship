# custom-completions

本目录下的补全脚本来自 [nushell/nu_scripts](https://github.com/nushell/nu_scripts)（MIT License）：

| 工具   | 文件                           | nu-version           | 加载方式                      |
| ------ | ------------------------------ | -------------------- | ----------------------------- |
| git    | `git/git-completions.nu`       | 0.102.0              | `use`                         |
| uv     | `uv/uv-completions.nu`         | 0.115.0（uv 0.12.5） | `use`                         |
| npm    | `npm/npm-completions.nu`       | —                    | `use`                         |
| pnpm   | `pnpm/pnpm-completions.nu`     | —                    | `use`                         |
| cargo  | `cargo/cargo-completions.nu`   | —                    | `use`（子命令签名，无根命令） |
| rustup | `rustup/rustup-completions.nu` | —                    | `use`                         |
| docker | `docker/docker-completions.nu` | —                    | `use`                         |
| mvn    | `mvn/mvn-completions.nu`       | —                    | `source`（未导出 extern）     |
| winget | `winget/winget-completions.nu` | —                    | `use`                         |
| ssh    | `ssh/ssh-completions.nu`       | 0.102.0              | `use`                         |
| vscode | `vscode/vscode-completions.nu` | —                    | `use`                         |
| rg     | `rg/rg-completions.nu`         | —                    | `use`                         |

由 `%APPDATA%\nushell\config.nu` 第 4 节加载。
本机 nu 版本为 0.116.1，以上补全均实测可加载；`vim = nvim` 别名在 config.nu 第 5 节。

- 上游仓库：https://github.com/nushell/nu_scripts
- 许可证：MIT License（详见上游仓库 LICENSE）
- 更新时间：2026-10-25
