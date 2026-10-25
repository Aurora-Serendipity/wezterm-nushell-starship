--- WezTerm 配置入口
---
--- 组织方式参考开源项目 https://github.com/QianSong1/wezterm-config (MIT)：
--- 入口只负责按顺序合并 config/ 下的功能模块，并注册 events/ 下的事件模块。
--- 模块间若出现重复配置项，config/init.lua 会告警并保留先加载的值。
local Config = require("config")

-- 事件类模块：右侧状态栏、标签标题、标签栏"+"按钮、窗口启动定位
require("events.right-status").setup()
require("events.tab-title").setup()
require("events.new-tab-button").setup()
require("events.window-position").setup()

return Config:init()
  :append(require("config.appearance"))
  :append(require("config.bindings"))
  :append(require("config.domains"))
  :append(require("config.fonts"))
  :append(require("config.general"))
  :append(require("config.launch")).options
