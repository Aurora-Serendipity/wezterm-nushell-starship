--- 通用行为、滚动缓冲、粘贴与超链接规则
return {
  -- 配置变更自动重载（入口文件改动会触发热重载；改子模块后若未生效可手动重载）
  automatically_reload_config = true,

  -- shell 正常退出时关闭对应标签/窗口（Windows 下输入 exit 不再残留 "[Process exited]"）
  exit_behavior = "CloseOnCleanExit",

  -- 回滚缓冲行数（WezTerm 默认 3500，参考方案为 5000）
  scrollback_lines = 5000,

  -- Windows 下粘贴时统一使用 CR 换行
  canonicalize_pasted_newlines = "CarriageReturn",

  -- 右侧状态栏刷新间隔（毫秒）；时间/电池显示依赖它
  status_update_interval = 1000,

  -- 超链接识别规则（参考方案）：括号/方括号/花括号/尖括号包裹的 URL、裸 URL、隐式 mailto
  hyperlink_rules = {
    { regex = "\\((\\w+://\\S+)\\)", format = "$1", highlight = 1 },
    { regex = "\\[(\\w+://\\S+)\\]", format = "$1", highlight = 1 },
    { regex = "\\{(\\w+://\\S+)\\}", format = "$1", highlight = 1 },
    { regex = "<(\\w+://\\S+)>", format = "$1", highlight = 1 },
    { regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+", format = "$0" },
    { regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0" },
  },
}
