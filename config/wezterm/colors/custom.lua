-- Tokyo Night Moon 之上的最小 colors 覆盖表
--
-- 设计说明：
--   * color_scheme 负责终端 ANSI 调色板，这里只覆盖 tabs / 滚动条 / 视觉铃 / 分割线
--     等界面元素，不引入与方案冲突的终端配色；
--   * tab_bar 的颜色与 events/tab-title.lua 的三态配色保持一致，
--     保证 retro 标签栏中自定义 cell 与标签背景、新建标签按钮颜色连续；
--   * 所有色值均取自 Tokyo Night Moon 色板。
return {
  tab_bar = {
    -- 标签栏空白区域
    background = "#1e2030",
    -- 活动标签：蓝底深色字
    active_tab = {
      bg_color = "#82aaff",
      fg_color = "#1e2030",
    },
    -- 非活动标签
    inactive_tab = {
      bg_color = "#2f334d",
      fg_color = "#828bb8",
    },
    -- 鼠标悬停的非活动标签
    inactive_tab_hover = {
      bg_color = "#3b4261",
      fg_color = "#c8d3f5",
    },
    -- “+” 新建标签按钮
    new_tab = {
      bg_color = "#1e2030",
      fg_color = "#828bb8",
    },
    new_tab_hover = {
      bg_color = "#2f334d",
      fg_color = "#c8d3f5",
    },
  },

  -- 滚动条滑块
  scrollbar_thumb = "#545c7e",
  -- 视觉铃闪烁色
  visual_bell = "#2f334d",
  -- 窗格分割线
  split = "#545c7e",
  -- 输入法组合光标（新版本 WezTerm 支持）
  compose_cursor = "#ff966c",
  -- 选中文本
  selection_bg = "#2f334d",
  selection_fg = "#c8d3f5",
}
