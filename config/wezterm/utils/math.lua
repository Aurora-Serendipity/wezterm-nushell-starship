--- 小工具：数值 clamp / round（右侧状态栏的电池电量显示会用到）
local M = {}

--- 将 x 限制在 [min, max] 区间内
---@param x number
---@param min number
---@param max number
---@return number
function M.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

--- 四舍五入；传入 increment 时按增量舍入
---@param x number
---@param increment number|nil
---@return number
function M.round(x, increment)
  if increment then
    return M.round(x / increment) * increment
  end
  return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

return M
