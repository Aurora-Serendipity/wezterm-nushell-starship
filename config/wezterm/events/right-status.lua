-- 右侧状态栏：日期时间 + 电池（台式机无电池时只显示日期时间，不报错）
--
-- 适配说明：
--   * update-right-status 每隔 status_update_interval（默认 1000ms）触发一次；
--   * 日期时间用 wezterm.strftime，格式与参考仓库一致：" %a %H:%M"；
--   * 电池用 wezterm.battery_info() 读取；返回空表（无电池）时跳过电池与分隔符；
--   * 所有 PUA 图标均已用 `wezterm ls-fonts --text` 验证命中
--     CaskaydiaCove Nerd Font（Nerd Fonts v3），语义见下；
--   * 配色：Tokyo Night Moon，电池颜色随充电/低电量状态变化。
--
-- 字形清单（已实测）：
--   U+F073  fa-calendar_days             日期时间
--   U+F007A..U+F0082 md-battery_10..90   放电电量 10%..90%
--   U+F0079 md-battery                   放电电量 100%
--   U+F089C / U+F0086..U+F0088 / U+F089D / U+F0089 / U+F089E / U+F008A..U+F008B / U+F0085
--                                       充电 10%..100%（码位不连续，按档位列在数组中）
local wezterm = require("wezterm")
local math = require("utils.math")

local M = {}

-- Tokyo Night Moon 色板（仅本模块用到的部分）
local palette = {
  bg = "#222436",
  bg_dark = "#1e2030",
  bg_highlight = "#2f334d",
  fg = "#c8d3f5",
  fg_dark = "#828bb8",
  blue = "#82aaff",
  cyan = "#86e1fc",
  green = "#c3e88d",
  red = "#ff757f",
  yellow = "#ffc777",
  dark3 = "#545c7e",
}

-- 日期时间图标：fa-calendar_days
local GLYPH_CALENDAR = utf8.char(0xF073)

-- 电池图标：数组下标 1..10 对应电量 10%..100%
-- 放电状态：md-battery_10 ... md-battery_90, md-battery（满）
local DISCHARGING_ICONS = {
  utf8.char(0xF007A), -- md-battery_10
  utf8.char(0xF007B), -- md-battery_20
  utf8.char(0xF007C), -- md-battery_30
  utf8.char(0xF007D), -- md-battery_40
  utf8.char(0xF007E), -- md-battery_50
  utf8.char(0xF007F), -- md-battery_60
  utf8.char(0xF0080), -- md-battery_70
  utf8.char(0xF0081), -- md-battery_80
  utf8.char(0xF0082), -- md-battery_90
  utf8.char(0xF0079), -- md-battery
}

-- 充电状态：md-battery_charging_10 ... md-battery_charging_100（码位不连续）
local CHARGING_ICONS = {
  utf8.char(0xF089C), -- md-battery_charging_10
  utf8.char(0xF0086), -- md-battery_charging_20
  utf8.char(0xF0087), -- md-battery_charging_30
  utf8.char(0xF0088), -- md-battery_charging_40
  utf8.char(0xF089D), -- md-battery_charging_50
  utf8.char(0xF0089), -- md-battery_charging_60
  utf8.char(0xF089E), -- md-battery_charging_70
  utf8.char(0xF008A), -- md-battery_charging_80
  utf8.char(0xF008B), -- md-battery_charging_90
  utf8.char(0xF0085), -- md-battery_charging_100
}

-- 追加一段 FormatItem：前景色 + 背景色 + 加粗 + 文本
---@param cells table
---@param fg string
---@param bg string
---@param text string
local function push(cells, fg, bg, text)
  table.insert(cells, { Foreground = { Color = fg } })
  table.insert(cells, { Background = { Color = bg } })
  table.insert(cells, { Attribute = { Intensity = "Bold" } })
  table.insert(cells, { Text = text })
end

-- 日期时间：图标 + 星期/时分
---@param cells table
local function push_date(cells)
  local text = wezterm.strftime(" %a %H:%M")
  push(cells, palette.blue, palette.bg_dark, GLYPH_CALENDAR .. text .. " ")
end

-- 电池：百分比 + 10 档图标；batteries 为 wezterm.battery_info() 的返回值
---@param cells table
---@param batteries table
local function push_battery(cells, batteries)
  local battery = batteries[1] -- 多电池设备只显示第一块，避免状态栏过长

  local soc = battery.state_of_charge or 0
  local percent = string.format("%.0f%%", soc * 100)
  local level = math.clamp(math.round(soc * 10), 1, 10)
  local charging = battery.state == "Charging"
  local icon = charging and CHARGING_ICONS[level] or DISCHARGING_ICONS[level]

  -- 电池颜色：充电绿、≤20% 红、≤50% 黄、其余正常前景色
  local fg = palette.fg
  if charging then
    fg = palette.green
  elseif soc <= 0.2 then
    fg = palette.red
  elseif soc <= 0.5 then
    fg = palette.yellow
  end

  push(cells, fg, palette.bg_dark, icon .. " " .. percent .. " ")
end

-- 纯函数：构造右侧状态栏文本；window 需要实现 set_right_status（便于自检时传假对象）
---@param window table|nil
---@return string text wezterm.format 之后的最终文本
function M.render(window)
  local cells = {}
  push_date(cells)

  -- 只有确实存在电池时才追加分隔符与电池段，台式机上仅显示时间
  local batteries = wezterm.battery_info()
  if #batteries > 0 then
    table.insert(cells, { Foreground = { Color = palette.dark3 } })
    table.insert(cells, { Background = { Color = palette.bg_dark } })
    table.insert(cells, { Text = " ~ " })
    push_battery(cells, batteries)
  end

  table.insert(cells, "ResetAttributes")
  local text = wezterm.format(cells)
  if window then
    window:set_right_status(text)
  end
  return text
end

-- 注册 WezTerm 事件
function M.setup()
  wezterm.on("update-right-status", function(window, _pane)
    M.render(window)
  end)
end

return M
