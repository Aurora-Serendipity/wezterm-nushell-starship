#requires -Version 7.0
<#
.SYNOPSIS
    终端配置健康检查（WezTerm + Nushell + Starship）。

.DESCRIPTION
    逐项检查本机终端环境与三份配置文件是否可用。
    退出码 0 = 全部通过；1 = 存在失败项。

.EXAMPLE
    pwsh -File .\scripts\verify.ps1
#>
[CmdletBinding()]
param(
    [string]$WezTermConfig   = (Join-Path $HOME '.config\wezterm\wezterm.lua'),
    [string]$NuConfig        = (Join-Path $env:APPDATA 'nushell\config.nu'),
    [string]$StarshipConfig  = (Join-Path $HOME '.config\starship.toml')
)

$ErrorActionPreference = 'Continue'
$script:pass = 0
$script:fail = 0
$script:info = 0

function Check {
    param([string]$Name, [bool]$Ok, [string]$Detail = '')
    if ($Ok) {
        $script:pass++
        Write-Host "  [OK]   $Name" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  [FAIL] $Name" -ForegroundColor Red
    }
    if ($Detail) { Write-Host "         $Detail" -ForegroundColor DarkGray }
}

function Info {
    param([string]$Name, [string]$Detail = '')
    $script:info++
    Write-Host "  [INFO] $Name" -ForegroundColor DarkCyan
    if ($Detail) { Write-Host "         $Detail" -ForegroundColor DarkGray }
}

function Find-Exe {
    param([string]$Name, [string[]]$Fallback = @())
    $c = Get-Command $Name -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    foreach ($p in $Fallback) { if ($p -and (Test-Path -LiteralPath $p)) { return $p } }
    return $null
}

function Get-Output {
    param([string]$Exe, [string[]]$Arguments)
    try { return (& $Exe @Arguments 2>&1 | Out-String) } catch { return "__ERR__ $($_.Exception.Message)" }
}

Write-Host ''
Write-Host '=== 终端配置健康检查（WezTerm + Nushell + Starship）===' -ForegroundColor Magenta
Write-Host ''

# ---------- 软件 ----------
Write-Host '[ 软件 ]' -ForegroundColor Cyan
$wezterm = Find-Exe 'wezterm' @(
    (Join-Path $env:LOCALAPPDATA 'Programs\WezTerm\wezterm.exe'),
    (Join-Path $env:ProgramFiles 'WezTerm\wezterm.exe')
)
Check 'WezTerm 已安装' ([bool]$wezterm) $(if ($wezterm) { $wezterm } else { 'PATH 和常见安装目录都没找到' })
if ($wezterm) { Check 'WezTerm 版本可读取' (((Get-Output $wezterm @('--version')).Trim()) -match '^wezterm') }

$nu = Find-Exe 'nu' @((Join-Path $env:LOCALAPPDATA 'Programs\nu\bin\nu.exe'), (Join-Path $HOME 'AppData\Local\Programs\nu\bin\nu.exe'))
Check 'Nushell 已安装' ([bool]$nu) $(if ($nu) { $nu } else { '未找到 nu.exe' })
if ($nu) { Check 'Nushell 版本可读取' (((Get-Output $nu @('--version')).Trim()) -match '^\d+\.\d+') }

$starship = Find-Exe 'starship' @((Join-Path $env:ProgramFiles 'starship\bin\starship.exe'))
Check 'Starship 已安装' ([bool]$starship) $(if ($starship) { $starship } else { '未找到 starship.exe' })
if ($starship) { Check 'Starship 版本可读取' (((Get-Output $starship @('--version')).Trim().Split("`n")[0]) -match '^starship') }

$nvim = Find-Exe 'nvim' @((Join-Path $env:ProgramFiles 'Neovim\bin\nvim.exe'))
Check 'Neovim 已安装（vim=nvim 别名依赖）' ([bool]$nvim) $(if ($nvim) { $nvim } else { '未找到 nvim.exe' })

$claude = Find-Exe 'claude' @((Join-Path $HOME '.local\bin\claude.exe'))
Info 'Claude Code（可选，cc 命令依赖）' $(if ($claude) { $claude } else { '未找到 claude（cc 仍可定义，但运行会失败）' })

$gcc = Find-Exe 'g++' @()
if ($gcc) { Info 'C/C++ 工具链存在（Starship c/cpp 模块会显示版本）' $gcc }
else { Info '未找到 g++/gcc（Starship c/cpp 模块不会出现，属正常）' }

# ---------- 字体 ----------
Write-Host ''
Write-Host '[ 字体 ]' -ForegroundColor Cyan
$ttf = 'CaskaydiaCoveNerdFont-Regular.ttf'
$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$fontOk = (Test-Path -LiteralPath (Join-Path $fontDir $ttf)) -or (Test-Path -LiteralPath (Join-Path $env:windir "Fonts\$ttf"))
Check 'CaskaydiaCove Nerd Font 文件存在' $fontOk "查找 $ttf"
if ($wezterm) {
    $fontOut = Get-Output $wezterm @('--config-file', $WezTermConfig, 'ls-fonts', '--text', 'abc')
    Check 'WezTerm 解析到 CaskaydiaCove' ($fontOut -match 'CaskaydiaCove') '解析不到说明字体未注册或字体名不对'
}

# ---------- 配置文件 ----------
Write-Host ''
Write-Host '[ 配置文件 ]' -ForegroundColor Cyan
Check 'WezTerm 配置存在' (Test-Path -LiteralPath $WezTermConfig) $WezTermConfig
Check 'Nushell 配置存在' (Test-Path -LiteralPath $NuConfig) $NuConfig
Check 'Starship 配置存在' (Test-Path -LiteralPath $StarshipConfig) $StarshipConfig

# ---------- WezTerm ----------
Write-Host ''
Write-Host '[ WezTerm 运行验证 ]' -ForegroundColor Cyan
if ($wezterm -and (Test-Path -LiteralPath $WezTermConfig)) {
    $keyOut = Get-Output $wezterm @('--config-file', $WezTermConfig, 'show-keys')
    Check 'WezTerm 配置能加载（show-keys 无 ERROR/WARN）' (($keyOut -notmatch 'ERROR') -and ($keyOut -notmatch 'WARN'))
    $fontPath = Join-Path (Split-Path -Parent $WezTermConfig) 'config\fonts.lua'
    $fontCfg = if (Test-Path -LiteralPath $fontPath) { Get-Content -LiteralPath $fontPath -Raw } else { '' }
    Check '字体连字已配置（harfbuzz_features）' ($fontCfg -match 'harfbuzz_features') $fontPath
    Check '自定义 leader 生效（Ctrl+A）' ($keyOut -match "Leader:\s*Char\('a'\)\s*CTRL")
    Check '键位数量合理（show-keys 行数 > 300）' (($keyOut -split "`n").Count -gt 300)
}

# ---------- Nushell ----------
Write-Host ''
Write-Host '[ Nushell 运行验证 ]' -ForegroundColor Cyan
if ($nu -and (Test-Path -LiteralPath $NuConfig)) {
    $nuOut = Get-Output $nu @('--config', $NuConfig, '-c', 'print "nu-config-ok"')
    Check 'Nushell 配置能加载' ($nuOut -match 'nu-config-ok')

    $clip = (Get-Output $nu @('--config', $NuConfig, '-c', 'print ($env.NU_EXPERIMENTAL_OPTIONS? | default "<unset>")')).Trim()
    Check 'native-clip 实验选项生效' ($clip -eq 'native-clip') "实际：$clip"

    $rl = (Get-Output $nu @('--config', $NuConfig, '-c', 'print ($env.config.render_right_prompt_on_last_line | into string)')).Trim()
    Check '右侧提示符最后一行设置生效' ($rl -eq 'true') "实际：$rl"

    $ccCount = (Get-Output $nu @('--config', $NuConfig, '-c', 'print ((scope commands | where name == "cc" | length) | into string)')).Trim()
    Check 'cc（Claude Code 包装）已定义' ($ccCount -eq '1') "scope 中 cc 数量：$ccCount"

    $extras = (Get-Output $nu @('--config', $NuConfig, '-c', 'print ((scope commands | where name in ["git" "uv" "npm" "pnpm" "cargo" "rustup" "docker" "mvn" "winget" "ssh" "code" "rg"] | length) | into string)')).Trim()
    Check '补全命令已注册（>= 11 个）' ([int]$extras -ge 11) "实际：$extras"

    $artCount = (Get-Output $nu @('--config', $NuConfig, '-c', 'print ((scope commands | where name in ["img" "art" "banner"] | length) | into string)')).Trim()
    Check 'img/art/banner 终端艺术命令已定义' ($artCount -eq '3') "实际：$artCount / 3"
    $tableSep = (Get-Output $nu @('--config', $NuConfig, '-c', 'print ($env.config.table.header_on_separator | into string)')).Trim()
    Check '表格表头分隔线已启用' ($tableSep -eq 'true') "实际：$tableSep"
    $pyenc = (Get-Output $nu @('--config', $NuConfig, '-c', 'print ($env.PYTHONIOENCODING? | default "<unset>")')).Trim()
    Check 'Python 输出编码为 UTF-8' ($pyenc -eq 'utf-8') "实际：$pyenc"
    $chafa = Get-Command chafa -ErrorAction SilentlyContinue
    $fastfetch = Get-Command fastfetch -ErrorAction SilentlyContinue
    Info '终端艺术可选工具' "chafa=$(if ($chafa) { 'OK' } else { 'MISS' })；fastfetch=$(if ($fastfetch) { 'OK' } else { 'MISS' })"
    $extraTools = @('onefetch','btop','vhs','agg','glow','tte')
    $extraStatus = $extraTools | ForEach-Object { "$_=$(if (Get-Command $_ -ErrorAction SilentlyContinue) { 'OK' } else { 'MISS' })" }
    Info '终端艺术扩展工具' ($extraStatus -join '；')
}

# ---------- Starship ----------
Write-Host ''
Write-Host '[ Starship 运行验证 ]' -ForegroundColor Cyan
if ($starship -and (Test-Path -LiteralPath $StarshipConfig)) {
    $env:STARSHIP_CONFIG = $StarshipConfig
    $left = Get-Output $starship @('prompt', '-w', '120')
    Check 'Starship 能渲染左提示符' ($left.Trim().Length -gt 0)

    $right = Get-Output $starship @('prompt', '--right', '-w', '120')
    Check 'Starship 右侧时间提示符可渲染' ($right -match '\d{1,2}:\d{2}')

    $auto = Join-Path $env:APPDATA 'nushell\vendor\autoload\starship.nu'
    Check 'Starship autoload 文件存在' (Test-Path -LiteralPath $auto) $auto

    $completions = Join-Path $env:APPDATA 'nushell\custom-completions'
    $cCount = 0
    if (Test-Path -LiteralPath $completions) { $cCount = (Get-ChildItem $completions -Directory).Count }
    Check '自定义补全目录已安装（>= 12 个）' ($cCount -ge 12) "实际：$cCount 个"

    $toml = Get-Content -LiteralPath $StarshipConfig -Raw
    Check 'c/cpp 模块已配置（含 [c] 与 [cpp]）' (($toml -match '(?m)^\[c\]') -and ($toml -match '(?m)^\[cpp\]'))
}

# ---------- 集成 ----------
Write-Host ''
Write-Host '[ 跨组件集成 ]' -ForegroundColor Cyan
Check 'wezterm 在 PATH 中（cc 改标签标题依赖）' ([bool](Get-Command wezterm -ErrorAction SilentlyContinue))

$wzDir = Split-Path -Parent (Split-Path -Parent $WezTermConfig)
if (Test-Path -LiteralPath (Join-Path $wzDir '.git')) {
    $st = (& git -C $wzDir status --porcelain 2>&1 | Out-String).Trim()
    if ($st) { Info 'WezTerm 配置 git 有未提交改动' (($st -split "`n" | Select-Object -First 3) -join '; ') }
    else { Info 'WezTerm 配置 git 工作区干净' }
}

# ---------- 可选：Windows 11 右键菜单 ----------
Write-Host ''
Write-Host '[ Windows 11 右键菜单（可选） ]' -ForegroundColor Cyan
$ctxPkg = Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object { $_.InstallLocation -like '*ContextMenuCustomDev*' }
if ($ctxPkg) {
    $ctxCfg = Join-Path $env:LOCALAPPDATA "Packages\$($ctxPkg.PackageFamilyName)\LocalState\custom_commands\Open WezTerm here.json"
    $ctxOk = $false
    if (Test-Path -LiteralPath $ctxCfg) {
        $txt = Get-Content -LiteralPath $ctxCfg -Raw
        $ctxOk = ($txt -match 'Open WezTerm here') -and ($txt -match 'wezterm-gui\.exe') -and ($txt -match '--cwd')
    }
    Check '一级右键菜单扩展包已注册' $true $ctxPkg.PackageFullName
    Check '右键菜单配置存在且指向 WezTerm' $ctxOk $ctxCfg
} else {
    Info '未安装 Windows 11 一级右键菜单（可选）' '安装：pwsh -File .\scripts\context-menu\install.ps1'
}
$classicBg = Test-Path -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\Background\shell\Open WezTerm here'
$classicDir = Test-Path -LiteralPath 'HKLM:\SOFTWARE\Classes\Directory\shell\Open WezTerm here'
if ($classicBg -and $classicDir) { Info '经典右键菜单回退项存在（显示更多选项）' }

# ---------- 汇总 ----------
Write-Host ''
if ($script:fail -eq 0) {
    Write-Host "全部通过（$script:pass 项检查，$script:info 项提示）" -ForegroundColor Green
    exit 0
}
Write-Host "通过 $script:pass 项，失败 $script:fail 项（$script:info 项提示）" -ForegroundColor Red
exit 1

