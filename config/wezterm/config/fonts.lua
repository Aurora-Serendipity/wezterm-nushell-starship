local wezterm = require("wezterm")

--- 字体配置：主力字体保持原配置的 CaskaydiaCove Nerd Font
--- （本机为 Nerd Fonts v3 字形集，缺失符号由 WezTerm 内置字体兜底）
return {
  font = wezterm.font("CaskaydiaCove Nerd Font"),
  font_size = 13,
}
