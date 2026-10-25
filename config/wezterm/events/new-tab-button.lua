-- 标签栏 “+” 新建标签按钮：左键执行默认动作，右键弹出带模糊搜索的启动器
--
-- 适配说明：
--   * 事件名：new-tab-button-click，回调参数为 (window, pane, button, default_action)；
--   * 右键弹 ShowLauncherArgs，flags 同时启用模糊匹配 / 启动菜单项 / domains；
--   * 返回 false 以阻止 WezTerm 的默认处理（避免右键也新建标签）；
--   * 标题前的放大镜图标 U+F0349 md-magnify 已用 `wezterm ls-fonts --text` 验证，
--     命中 CaskaydiaCove Nerd Font（Nerd Fonts v3）。
local wezterm = require("wezterm")

local M = {}

-- 右键启动器标题：放大镜 + 文案
local LAUNCHER_TITLE = utf8.char(0xF0349) .. " Select/Search:"

-- 处理 “+ 按钮” 点击：左键默认新建，右键打开启动器
---@param window table
---@param pane table
---@param button string "Left" / "Right"
---@param default_action table|nil
---@return boolean 返回 false 以阻止默认处理
function M.handle(window, pane, button, default_action)
  if default_action and button == "Left" then
    -- 左键：保持 WezTerm 默认的“新建标签”行为
    window:perform_action(default_action, pane)
  elseif default_action and button == "Right" then
    -- 右键：启动器（模糊搜索 + 启动菜单 + 域）
    window:perform_action(wezterm.action.ShowLauncherArgs({
      title = LAUNCHER_TITLE,
      flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
    }), pane)
  end
  return false
end

-- 注册 WezTerm 事件
function M.setup()
  wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
    return M.handle(window, pane, button, default_action)
  end)
end

return M
