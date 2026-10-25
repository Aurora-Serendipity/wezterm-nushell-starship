local wezterm = require("wezterm")

--- 判断 wezterm.target_triple 中是否包含指定片段
---@param str string
---@param pattern string
---@return boolean
local function is_found(str, pattern)
  return string.find(str, pattern) ~= nil
end

--- 返回当前平台信息，供各配置模块做平台分支
--- 用法：local platform = require("utils.platform")()
---@return { is_win: boolean, is_linux: boolean, is_mac: boolean }
return function()
  return {
    is_win = is_found(wezterm.target_triple, "windows"),
    is_linux = is_found(wezterm.target_triple, "linux"),
    is_mac = is_found(wezterm.target_triple, "apple"),
  }
end
