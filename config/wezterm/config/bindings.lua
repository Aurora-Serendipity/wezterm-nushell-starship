local wezterm = require("wezterm")
local act = wezterm.action

--- 按键与鼠标绑定
---
--- 说明：
--- * 原配置（单文件版）中的 15 条显式绑定 + 8 条 Ctrl+1..8 循环绑定逐条保留，行为不变；
--- * 参考方案在 Windows 上用 Alt 充当 SUPER 修饰键，容易与 Nushell/Bash 的 Alt 快捷键冲突，
---   因此不移植整套 Alt 键位，只追加与 shell 不冲突的功能键与 leader 键表绑定；
--- * 原配置的 2 条鼠标绑定同样保留。
local keys = {
  -- ===== 原配置：退出 / 分屏 / 窗格操作 =====
  { key = "q", mods = "CTRL", action = act.QuitApplication },

  { key = "h", mods = "LEADER", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "v", mods = "LEADER", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "q", mods = "LEADER", action = act.CloseCurrentPane { confirm = false } },

  { key = "LeftArrow", mods = "CTRL", action = act.ActivatePaneDirection "Left" },
  { key = "RightArrow", mods = "CTRL", action = act.ActivatePaneDirection "Right" },
  { key = "UpArrow", mods = "CTRL", action = act.ActivatePaneDirection "Up" },
  { key = "DownArrow", mods = "CTRL", action = act.ActivatePaneDirection "Down" },

  -- 原配置：Ctrl + T 新建默认标签，Ctrl + W 关闭当前标签
  { key = "t", mods = "CTRL", action = act.SpawnTab "DefaultDomain" },
  { key = "w", mods = "CTRL", action = act.CloseCurrentTab { confirm = false } },

  -- 原配置：Ctrl + Shift + 符号键 创建指定 shell 的标签
  {
    key = "!",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      domain = "DefaultDomain",
      args = { "wsl", "-d", "Ubuntu-24.04" },
    },
  },
  {
    key = "@",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      domain = "DefaultDomain",
      args = { "wsl", "-d", "kali-linux" },
    },
  },
  {
    key = "#",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      domain = "DefaultDomain",
      args = { "wsl", "-d", "archlinux" },
    },
  },
  {
    key = "$",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "cmd" },
    },
  },
  {
    key = "%",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      domain = "DefaultDomain",
      args = { "pwsh" },
    },
  },

  -- ===== 以下为参考方案补充：功能键（不与 shell 常用键冲突） =====
  { key = "F1", mods = "NONE", action = act.ActivateCopyMode },
  { key = "F2", mods = "NONE", action = act.ActivateCommandPalette },
  { key = "F3", mods = "NONE", action = act.ShowLauncher },
  { key = "F4", mods = "NONE", action = act.ShowTabNavigator },
  { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
  { key = "F12", mods = "NONE", action = act.ShowDebugOverlay },

  -- 复制/粘贴：Windows 默认已有同款绑定，这里显式写出便于查阅
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },

  -- 重命名当前标签页（参考方案使用 Ctrl+Shift+R）。
  -- 注意：Ctrl+Shift+R 同时是 WezTerm 默认的"重载配置"快捷键，
  -- 因此这里额外把重载配置移到 Ctrl+Shift+Alt+R，避免功能丢失。
  {
    key = "R",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine {
      description = "输入新的标签页名称",
      action = wezterm.action_callback(function(window, _pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  { key = "R", mods = "CTRL|SHIFT|ALT", action = act.ReloadConfiguration },

  -- 参考方案：leader 键表（Leader 前缀键后按 p 调窗格尺寸、按 f 调字号）
  {
    key = "p",
    mods = "LEADER",
    action = act.ActivateKeyTable {
      name = "resize_pane",
      one_shot = false,
      timeout_milliseconds = 1000,
    },
  },
  {
    key = "f",
    mods = "LEADER",
    action = act.ActivateKeyTable {
      name = "resize_font",
      one_shot = false,
      timeout_milliseconds = 1000,
    },
  },
}

-- 原配置：Ctrl + 数字 激活对应标签页
for i = 1, 8 do
  table.insert(keys, {
    key = tostring(i),
    mods = "CTRL",
    action = act.ActivateTab(i - 1),
  })
end

--- leader 键表定义（参考方案）
local key_tables = {
  -- 模拟 tmux 的 hjkl 调窗格尺寸
  resize_pane = {
    { key = "k", action = act.AdjustPaneSize { "Up", 1 } },
    { key = "j", action = act.AdjustPaneSize { "Down", 1 } },
    { key = "h", action = act.AdjustPaneSize { "Left", 1 } },
    { key = "l", action = act.AdjustPaneSize { "Right", 1 } },
    { key = "Escape", action = act.PopKeyTable },
    { key = "q", action = act.PopKeyTable },
  },
  -- kj 缩小/放大字体，r 重置
  resize_font = {
    { key = "k", action = act.IncreaseFontSize },
    { key = "j", action = act.DecreaseFontSize },
    { key = "r", action = act.ResetFontSize },
    { key = "Escape", action = act.PopKeyTable },
    { key = "q", action = act.PopKeyTable },
  },
}

--- 鼠标绑定：原配置逐条保留
local mouse_bindings = {
  -- 左键单击选中后松开，把选区复制到剪贴板 + 主选择缓冲区
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection "ClipboardAndPrimarySelection",
  },
  -- 按住 CTRL 左键单击，用默认浏览器打开鼠标下的超链接
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  -- 以下两条来自 wezterm-kit（MIT）：WezTerm 默认没有右键绑定。
  -- 右键 = 粘贴，Shift+右键 = 复制选中内容。
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom "Clipboard",
  },
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "SHIFT",
    action = act.CopyTo "Clipboard",
  },
}

return {
  -- 保持原配置行为：不禁用 WezTerm 自带的默认键鼠绑定
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
  keys = keys,
  key_tables = key_tables,
  mouse_bindings = mouse_bindings,
}
