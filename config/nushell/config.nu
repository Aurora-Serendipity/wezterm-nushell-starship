# Nushell Config File
#
# version = "0.116.1"
#
# 组织方式参考 Byxs20/terminal_config 的 nushell 方案（单文件、按功能分节），
# 并已按本机环境适配；原配置文件中的全部内容均已保留：
#   * $env.NU_EXPERIMENTAL_OPTIONS = "native-clip"
#   * 每次启动重新生成 vendor/autoload 下的 Starship 提示符脚本

# ============================================================
# 1. 主题
# ------------------------------------------------------------
# 参考方案中的 color_config 基于旧版本 nu（0.110），与 0.116 默认主题相比
# 只有两处不同，但整体覆盖会丢失 0.116 新增的 binary_*/semver*/selection*
# 等颜色键。因此这里只把方案里的两个差异项 merge 进来。
# ============================================================
$env.config.color_config = ($env.config.color_config | merge {
    hints: '#6c6c6c'
    shape_matching_brackets: { attr: u }
})

# ============================================================
# 2. 提示符：Starship
# ------------------------------------------------------------
# 保留原有机制：每次启动重新生成 vendor/autoload 下的 Starship 脚本。
# 参考方案中的自定义 PROMPT_COMMAND 未采用，避免覆盖 Starship 提示符。
# ============================================================
$env.NU_EXPERIMENTAL_OPTIONS = "native-clip"

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# ============================================================
# 3. 启动行为
# ============================================================
# 不显示启动信息
$env.config.show_banner = false
# 避免输入回车出现位移情况
$env.config.shell_integration.osc133 = false
# 右侧提示符渲染在提示符最后一行（Starship right_format 的时间右对齐在此位置）
$env.config.render_right_prompt_on_last_line = true

# ============================================================
# 4. 命令补全
# ------------------------------------------------------------
# 来自 nu_scripts（MIT License）：
# https://github.com/nushell/nu_scripts/tree/main/custom-completions
# ============================================================
use ~/AppData/Roaming/nushell/custom-completions/git/git-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/uv/uv-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/npm/npm-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/pnpm/pnpm-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/cargo/cargo-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/rustup/rustup-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/docker/docker-completions.nu *
# mvn 补全文件使用未导出的 extern 定义，需用 source 引入（use * 不会生效）
source ~/AppData/Roaming/nushell/custom-completions/mvn/mvn-completions.nu
use ~/AppData/Roaming/nushell/custom-completions/winget/winget-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/ssh/ssh-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/vscode/vscode-completions.nu *
use ~/AppData/Roaming/nushell/custom-completions/rg/rg-completions.nu *

# ============================================================
# 5. 别名 / 目录常量
# ------------------------------------------------------------
# 参考方案中的 alias vim = nvim 已采纳（Neovim 已通过 winget 安装）。
# 目录常量（ToolsDir/ScriptDir/WSLDir）属于作者个人环境，未采纳。
# ============================================================
alias vim = nvim

# 参考 wezterm-kit 的 AI CLI 快捷命令（snippets/claude.nu，MIT）：
# 启动 Claude Code 前先把当前 WezTerm 标签页标题改为 Claude。
# --wrapped 让 cc 的未知参数（如 --version/--resume）原样透传给 claude；
# 仅在 WezTerm 里才改标签标题，避免在其它终端里报错。
def --wrapped cc [...args: string] {
    if ((($env.WEZTERM_PANE? | default "") | is-empty) == false) {
        wezterm cli set-tab-title "Claude"
    }
    claude ...$args
}

# ============================================================
# 6. 代理辅助
# ------------------------------------------------------------
# 参考方案中的 proxy set / proxy unset / proxy check 未采纳（本机不需要）。
# ============================================================

# ============================================================
# 7. 工具路径别名
# ------------------------------------------------------------
# 参考方案中的 CTF 工具别名基于作者个人路径，未采纳。
# ============================================================
