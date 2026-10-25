local wezterm = require("wezterm")
local platform = require("utils.platform")()
local colors = require("colors.custom")

--- 外观配置：配色、背景、窗口、标签栏、滚动条、光标
local options = {
  ---- 配色 ----
  -- 主配色保持原配置的 Tokyo Night Moon；colors.custom 仅做少量覆盖（标签栏/滚动条/选区等）
  color_scheme = "Tokyo Night Moon",
  colors = colors,

  ---- 背景 ----
  -- 原配置：0.7 窗口透明度 + 背景图；
  -- 背景图已复制进 backdrops/，改用 wezterm.config_dir 引用，实现配置目录自包含
  window_background_opacity = 0.7,
  background = {
    {
      source = { File = wezterm.config_dir .. "/backdrops/flower-meadow.jpg" },
      -- 背景图层增强（思路来自 wezterm-kit）：
      -- 默认 Cover 缩放铺满窗口；这里改为居中裁剪，让画面主体居中。
      -- hsb 可单独压暗/调色背景图，不影响文字；窗口整体透明度仍保持上面的 0.7。
      horizontal_align = "Center",
      vertical_align = "Middle",
      repeat_x = "NoRepeat",
      repeat_y = "NoRepeat",
      hsb = {
        brightness = 0.9,
        saturation = 1.0,
        hue = 1.0,
      },
    },
  },

  ---- 窗口 ----
  -- 用户已确认采用参考方案的一体化细标题栏（原配置为 "TITLE | RESIZE"）
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  integrated_title_button_style = "Windows",
  integrated_title_button_color = "auto",
  integrated_title_button_alignment = "Right",
  window_frame = {
    active_titlebar_bg = "#1e2030",
    inactive_titlebar_bg = "#1e2030",
  },
  -- 初始窗口尺寸保持原配置
  initial_cols = 130,
  initial_rows = 50,
  window_padding = { left = 6, right = 6, top = 6, bottom = 6 },
  adjust_window_size_when_changing_font_size = false,

  ---- 标签栏 ----
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  show_tab_index_in_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  tab_max_width = 25,
  switch_to_last_active_tab_when_closing_tab = true,

  ---- 滚动条 ----
  enable_scroll_bar = true,
  min_scroll_bar_height = "3cell",

  ---- 光标 ----
  default_cursor_style = "BlinkingBlock",
  cursor_blink_rate = 700,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",

  ---- 非活动窗格 ----
  inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 },
}

-- 原配置中的 macOS 专属项：在 Windows 下不生效，用平台分支保留，避免内容丢失
if platform.is_mac then
  options.macos_window_background_blur = 10
end

return options
