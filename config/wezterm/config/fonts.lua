local wezterm = require("wezterm")

--- 字体配置：主力字体保持原配置的 CaskaydiaCove Nerd Font
--- （本机为 Nerd Fonts v3 字形集，缺失符号由 WezTerm 内置字体兜底）
--- 连字：CaskaydiaCove 支持 ->、=>、!= 等编程连字；
--- 显式开启标准 ligature 特性，避免升级/换字体后被默认关闭。
return {
  font = wezterm.font("CaskaydiaCove Nerd Font"),
  font_size = 13,
  harfbuzz_features = { "calt=1", "liga=1", "clig=1" },
}
