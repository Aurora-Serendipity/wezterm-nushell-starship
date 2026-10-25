-- 自定义标签标题（retro 标签栏）：Powerline 半圆 + 状态图标 + 三态配色
--
-- 适配说明：
--   * 目标标签栏为 retro 模式（use_fancy_tab_bar = false），format-tab-title 返回的
--     cell 会按终端字体渲染，因此 Powerline 半圆与图标都必须能在所用字体中解析；
--   * 字体：CaskaydiaCove Nerd Font（Nerd Fonts v3 字形集）；
--   * 所有 PUA 字形都已用 `wezterm ls-fonts --text` 逐个验证，码位/字形名见下；
--   * 配色：Tokyo Night Moon；三态配色与 colors/custom.lua 的 tab_bar 覆盖保持一致，
--     使自定义 cell 与标签栏背景、新建标签按钮的颜色连续。
--
-- 字形清单（已实测）：
--   U+E0B6 ple-left_half_circle_thick   左半圆（WezTerm 默认内建绘制，字形本身在字体中）
--   U+E0B4 ple-right_half_circle_thick  右半圆（同上）
--   U+F120 fa-terminal                  前台进程
--   U+F040 fa-pencil                    重命名后的静态标题
--   U+F018D md-console                  回退到窗格标题
--   U+F05B3 md-microsoft_windows        管理员窗口
--   U+F009A md-bell                     有未读输出
local wezterm = require("wezterm")

local M = {}

-- Tokyo Night Moon 色板（仅本模块用到的部分）
local palette = {
  bg = "#222436", -- 主背景
  bg_dark = "#1e2030", -- 深背景
  bg_highlight = "#2f334d",
  fg = "#c8d3f5",
  fg_dark = "#828bb8",
  blue = "#82aaff",
  red = "#ff757f",
  orange = "#ff966c",
  yellow = "#ffc777",
  green = "#c3e88d",
  dark3 = "#545c7e",
}

-- 标签三态配色（与 colors/custom.lua 的 tab_bar 覆盖一致）
local tab_colors = {
  -- 活动标签：蓝底深色字
  active = { bg = palette.blue, fg = palette.bg_dark },
  -- 悬停标签：偏亮的灰蓝
  hover = { bg = "#3b4261", fg = palette.fg },
  -- 非活动标签：深灰底、次级前景色
  default = { bg = palette.bg_highlight, fg = palette.fg_dark },
}

-- 图标字形：统一用 utf8.char 生成，避免源文件编码问题；码位见文件头注释
local GLYPH = {
  left_half_circle = utf8.char(0xE0B6), -- 左半圆
  right_half_circle = utf8.char(0xE0B4), -- 右半圆
  process = utf8.char(0xF120), -- 前台进程
  static_title = utf8.char(0xF040), -- 重命名后的标题
  pane_title = utf8.char(0xF018D), -- 窗格标题回退
  admin = utf8.char(0xF05B3), -- 管理员窗口
  bell = utf8.char(0xF009A), -- 未读输出
}

-- 当前事件要返回的 FormatItem 列表（每次渲染前重置）
M.cells = {}

-- 瞬时进程 / 友好名称映射：
--   * starship / oh-my-posh 是提示符渲染器，只在出提示符时短暂运行，直接显示会让标签名闪烁，忽略之；
--   * wslhost 是 WSL 会话的宿主进程，统一显示为 wsl 更直观。
local IGNORED_PROCESSES = { starship = true, ["oh-my-posh"] = true }
local PROCESS_ALIASES = { wslhost = "wsl" }

-- 从 foreground_process_name 提取进程名：去掉目录前缀与 .exe 后缀
---@param s string|nil
---@return string
local function process_name(s)
  if not s or s == "" then
    return ""
  end
  local name = s:gsub("(.*[/\\])(.*)", "%2")
  return (name:gsub("%.exe$", ""))
end

-- 管理员检测：Windows 提权后的控制台标题以 "Administrator: " 开头
---@param pane_title string|nil
---@return boolean
local function is_admin(pane_title)
  return pane_title ~= nil and pane_title:match("^Administrator: ") ~= nil
end

-- 追加一个加粗 cell（背景色 / 前景色 / 文本）
---@param bg string
---@param fg string
---@param text string
local function push_cell(bg, fg, text)
  table.insert(M.cells, { Background = { Color = bg } })
  table.insert(M.cells, { Foreground = { Color = fg } })
  table.insert(M.cells, { Attribute = { Intensity = "Bold" } })
  table.insert(M.cells, { Text = text })
end

-- 根据 tab 的状态选择图标与标题文本
---@param tab table
---@return string icon 图标
---@return string text 标题文本
local function pick_title(tab)
  local process = process_name(tab.active_pane and tab.active_pane.foreground_process_name)
  if IGNORED_PROCESSES[process] then
    process = ""
  end
  process = PROCESS_ALIASES[process] or process
  local static_title = tab.tab_title or ""
  local pane_title = (tab.active_pane and tab.active_pane.title) or ""

  -- 优先级：前台进程名 > 重命名后的静态标题 > 窗格标题
  if process ~= "" and static_title == "" then
    return GLYPH.process, process
  elseif static_title ~= "" then
    return GLYPH.static_title, static_title
  end
  return GLYPH.pane_title, pane_title
end

-- 是否有未读输出：遍历 tab.panes 检查 has_unseen_output
---@param tab table
---@return boolean
local function has_unseen_output(tab)
  for _, pane in ipairs(tab.panes or {}) do
    if pane.has_unseen_output then
      return true
    end
  end
  return false
end

-- 纯函数：构造一个标签的 cell 列表，便于入口复用与自检
---@param tab table format-tab-title 的第一个参数
---@param hover boolean 鼠标是否悬停
---@param max_width number 该标签可用的最大字符格数
---@return table cells FormatItem 列表
function M.render(tab, hover, max_width)
  max_width = max_width or 40

  local admin = is_admin(tab.active_pane and tab.active_pane.title)
  local unseen = has_unseen_output(tab)

  -- 三态配色：活动 > 悬停 > 默认
  local state = tab_colors.default
  if tab.is_active then
    state = tab_colors.active
  elseif hover then
    state = tab_colors.hover
  end

  local icon, text = pick_title(tab)
  -- 保留原配置 show_tab_index_in_tab_bar 的行为：
  -- 自定义 format-tab-title 时 WezTerm 不会自动加序号，这里手动补 "N: " 前缀
  -- （retro 标签栏默认样式同样是 "序号: 标题"）。
  local index = tostring((tab.tab_index or 0) + 1) .. ": "
  local title = index .. icon .. " " .. text

  -- 固定占用：左半圆 1 + 左空格 1 + 右空格 1 + 右半圆 1 = 4
  -- 管理员图标 / 未读铃铛各占 2（图标 + 空格）。
  -- 注意：序号已包含在 title 里参与截断预算，不能再从 available 中重复扣除，
  -- 否则 WezTerm 第二次调用（max_width 会收缩到第一次测量出的标签宽度）会把进程名截掉。
  local fixed = 4 + (admin and 2 or 0) + (unseen and 2 or 0)
  local available = math.max(1, math.floor(max_width - fixed))
  -- truncate_right 按显示宽度截断，避免中文/图标按字节截断导致的过早裁剪
  title = wezterm.truncate_right(title, available)

  M.cells = {}
  -- 左半圆反色：背景=文字色、前景=标签底色，形成圆角
  push_cell(state.fg, state.bg, GLYPH.left_half_circle)
  push_cell(state.bg, state.fg, " ")
  -- 管理员窗口：标题前加 Windows 徽标
  if admin then
    push_cell(state.bg, state.fg, GLYPH.admin .. " ")
  end
  -- 标题主体（图标 + 名称），加粗
  push_cell(state.bg, state.fg, title)
  -- 未读输出：黄色铃铛提示
  if unseen then
    push_cell(state.bg, palette.yellow, " " .. GLYPH.bell)
  end
  push_cell(state.bg, state.fg, " ")
  -- 右半圆反色
  push_cell(state.fg, state.bg, GLYPH.right_half_circle)

  return M.cells
end

-- 注册 WezTerm 事件
function M.setup()
  wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
    return M.render(tab, hover, max_width)
  end)
end

return M
