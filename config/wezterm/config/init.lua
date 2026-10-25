local wezterm = require("wezterm")

---@class Config
---@field options table
local Config = {}

--- 初始化一个配置累加器。
--- 底层使用 wezterm.config_builder()：向未知配置项赋值时会给出告警，
--- 便于在重构/维护时尽早发现拼写错误（参考方案只用了普通 table）。
---@return Config
function Config:init()
  local o = {}
  self = setmetatable(o, { __index = Config })
  self.options = wezterm.config_builder()
  return o
end

--- 把各模块返回的选项表追加进 Config.options。
--- 同名配置项保留第一次写入的值并打印告警，避免后加载模块静默覆盖先加载的显式配置。
---@param new_options table
---@return Config
function Config:append(new_options)
  for k, v in pairs(new_options) do
    if self.options[k] ~= nil then
      wezterm.log_warn("检测到重复的配置项，已保留先加载的值", { old = self.options[k], new = v })
    else
      self.options[k] = v
    end
  end
  return self
end

return Config
