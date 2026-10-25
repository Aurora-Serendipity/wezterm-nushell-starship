--- 多路复用域配置（沿用参考方案的结构，内容替换为本机环境）
return {
  -- 本机暂无固定的 SSH 远端主机，保留空表；
  -- 需要时可仿照参考方案补充 name/remote_address/username/ssh_option 后加入 ssh_domains。
  ssh_domains = {},

  -- Windows 下一般用不到 Unix domain socket，保留空表占位。
  unix_domains = {},

  -- WSL 发行版域：供启动器（F3、右键"+"按钮）以及多路复用场景选择。
  -- 仅声明域，不改变原有 Ctrl+Shift+1..3 直接拉起 wsl 的行为。
  wsl_domains = {
    { name = "WSL:Ubuntu-24.04", distribution = "Ubuntu-24.04" },
    { name = "WSL:kali-linux", distribution = "kali-linux" },
    { name = "WSL:archlinux", distribution = "archlinux" },
  },
}
