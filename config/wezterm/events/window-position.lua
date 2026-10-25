local wezterm = require("wezterm")

local M = {}

--- 窗口启动逻辑：原配置行为 + 借鉴 wezterm-kit 的 cwd/居中增强。
---   * 无启动参数：保持原行为——活动屏 50% 尺寸、按命名屏原点居中 spawn；
---   * 带启动参数（例如资源管理器右键 "Open WezTerm here" 传入的 --cwd）：
---     原样传递 cmd（保留 args/cwd），并在 spawn 后用活动屏坐标居中。
M.setup = function()
  wezterm.on("gui-startup", function(cmd)
    local screen = wezterm.gui.screens().active
    local width, height = screen.width * 0.5, screen.height * 0.5

    local tab, pane, window = wezterm.mux.spawn_window(cmd or {
      position = {
        x = (screen.width - width) / 2,
        y = (screen.height - height) / 2,
        origin = { Named = screen.name },
      },
    })
    local gui_window = window:gui_window()

    -- 带参数启动时也居中；screen.x / screen.y 兼容多显示器与非主屏
    if cmd then
      gui_window:set_position(screen.x + (screen.width - width) / 2, screen.y + (screen.height - height) / 2)
    end

    gui_window:set_inner_size(width, height)
  end)
end

return M
