--- 默认 shell 与启动菜单
--- 原配置的 default_prog 与 launch_menu 两项完整保留，仅修正标签拼写并追加参考方案的常用入口。
--- 仓库版把本机绝对路径改为 wezterm.home_dir（对应 winget 的用户级安装位置），
--- 方便在其他 Windows 机器上直接使用；若 Nushell 不在该路径，请见 docs/customization.md。
local wezterm = require("wezterm")
local nu = wezterm.home_dir .. "\\AppData\\Local\\Programs\\nu\\bin\\nu.exe"

return {
  -- 默认启动 shell：Nushell
  default_prog = { nu },

  launch_menu = {
    -- 原配置两项（"PoserShell" 拼写修正为 "PowerShell"，启动参数 -NoLogo 保持）
    { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } },
    { label = "Cmd", args = { "cmd.exe" } },

    -- 以下为参考方案补充的常用入口
    { label = "PowerShell v7", args = { "pwsh" } },
    { label = "Nushell", args = { nu } },
    -- 下面的 WSL 发行版名称按本机环境填写；使用前请改成你自己的发行版（见 docs/customization.md）
    { label = "WSL: Ubuntu-24.04", args = { "wsl", "-d", "Ubuntu-24.04" } },
    { label = "WSL: Kali Linux", args = { "wsl", "-d", "kali-linux" } },
    { label = "WSL: Arch Linux", args = { "wsl", "-d", "archlinux" } },
  },
}
