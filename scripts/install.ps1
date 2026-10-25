#requires -Version 7.0
<#
.SYNOPSIS
    Windows 11 终端配置一键安装脚本（WezTerm + Nushell + Starship）。

.DESCRIPTION
    把本仓库的完整配置安装到当前用户目录，并自动处理依赖、备份与基础校验。
    默认行为：
      1. 通过 winget 安装/检查 WezTerm、Nushell、Starship、Neovim
      2. 安装 CaskaydiaCove Nerd Font（可 -SkipFont 跳过）
      3. 备份并复制 WezTerm / Nushell / Starship 配置
      4. 校验配置可加载
      5. 可选安装 Windows 11 一级右键菜单（-WithContextMenu）

.PARAMETER SkipFont
    跳过 Nerd Font 下载安装（适合已经安装过字体的机器）。

.PARAMETER WithContextMenu
    额外安装 Windows 11 新右键菜单一级项 "Open WezTerm here"（需要开发者模式，可选）。

.PARAMETER NoRestartExplorer
    安装右键菜单时不重启资源管理器。

.PARAMETER DryRun
    只打印将执行的操作，不修改任何文件/注册表/PATH。

.EXAMPLE
    pwsh -File .\scripts\install.ps1

.EXAMPLE
    pwsh -File .\scripts\install.ps1 -SkipFont -WithContextMenu
#>
[CmdletBinding()]
param(
    [switch]$SkipFont,
    [switch]$WithContextMenu,
    [switch]$NoRestartExplorer,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ConfigRoot = Join-Path $RepoRoot 'config'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Write-Step([string]$Message) { Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Info([string]$Message) { Write-Host "    $Message" -ForegroundColor DarkGray }
function Write-Ok([string]$Message) { Write-Host "    [OK] $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "    [WARN] $Message" -ForegroundColor Yellow }

function Refresh-Path {
    $env:PATH = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Backup-Path([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $bak = "$Path.bak-$Stamp"
    if ($DryRun) { Write-Info "会备份 $Path -> $bak"; return }
    Move-Item -LiteralPath $Path -Destination $bak -Force
    Write-Ok "已备份 $(Split-Path $Path -Leaf) -> $(Split-Path $bak -Leaf)"
}

function Copy-Tree([string]$Source, [string]$Target) {
    if ($DryRun) { Write-Info "会复制 $Source -> $Target"; return }
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    Copy-Item -Path (Join-Path $Source '*') -Destination $Target -Recurse -Force
}

function Find-WezTerm {
    $cmd = Get-Command wezterm -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($p in @(
            (Join-Path $env:LOCALAPPDATA 'Programs\WezTerm\wezterm.exe'),
            (Join-Path $env:ProgramFiles 'WezTerm\wezterm.exe'))) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

function Find-Nu {
    $cmd = Get-Command nu -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $p = Join-Path $HOME 'AppData\Local\Programs\nu\bin\nu.exe'
    if (Test-Path -LiteralPath $p) { return $p }
    return $null
}

function Ensure-Package([string]$Id, [string]$Command, [string]$Name) {
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Ok "$Name 已安装"
        return
    }
    if ($DryRun) { Write-Info "会通过 winget 安装 $Name ($Id)"; return }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "找不到 winget，无法自动安装 $Name。请手动安装 $Name 后重试。"
    }
    Write-Info "winget install --id $Id ..."
    & winget install --id $Id --source winget --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "winget 安装 $Name 返回 $LASTEXITCODE（可能已安装或需要重试）。"
    }
    Refresh-Path
}

function Ensure-UserPath([string]$Dir) {
    if (-not $Dir -or -not (Test-Path -LiteralPath $Dir)) { return }
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @($userPath -split ';' | Where-Object { $_ })
    if ($parts -contains $Dir) { return }
    if ($DryRun) { Write-Info "会把 $Dir 加入用户 PATH"; return }
    [Environment]::SetEnvironmentVariable('Path', (($parts + $Dir) -join ';'), 'User')
    Refresh-Path
    Write-Ok "已加入用户 PATH：$Dir"
}

function Install-NerdFont {
    $fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    $probe = Join-Path $fontDir 'CaskaydiaCoveNerdFont-Regular.ttf'
    if (Test-Path -LiteralPath $probe) {
        Write-Ok 'CaskaydiaCove Nerd Font 已安装'
        return
    }
    if ($DryRun) { Write-Info '会下载并安装 CaskaydiaCove Nerd Font'; return }

    Write-Info '下载 CaskaydiaCove Nerd Font ...'
    $url = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CaskaydiaCove.zip'
    $zip = Join-Path $env:TEMP "CaskaydiaCove-$Stamp.zip"
    $downloaded = $false
    for ($i = 1; $i -le 3 -and -not $downloaded; $i++) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -TimeoutSec 120
            $downloaded = (Test-Path $zip) -and ((Get-Item $zip).Length -gt 1MB)
        } catch { Write-Warn "字体下载失败（第 $i 次）：$($_.Exception.Message)" }
        if (-not $downloaded) { Start-Sleep -Seconds 3 }
    }
    if (-not $downloaded) {
        try {
            & curl.exe -L --retry 3 --retry-delay 3 -o $zip $url
            $downloaded = (Test-Path $zip) -and ((Get-Item $zip).Length -gt 1MB)
        } catch { }
    }
    if (-not $downloaded) {
        Write-Warn '字体自动下载失败。请手动下载并安装：'
        Write-Warn 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CaskaydiaCove.zip'
        return
    }

    $extract = Join-Path $env:TEMP "CaskaydiaCove-$Stamp"
    if (Test-Path $extract) { Remove-Item -Recurse -Force $extract }
    Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force
    New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
    $fonts = Get-ChildItem $extract -Recurse -Filter *.ttf
    foreach ($f in $fonts) { Copy-Item $f.FullName (Join-Path $fontDir $f.Name) -Force }

    try {
        if (-not ('Win32.FontApi' -as [type])) {
            Add-Type -Name FontApi -Namespace Win32 -MemberDefinition @'
[DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern int AddFontResourceW(string lpFileName);
[DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
'@
        }
        $reg = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
        New-Item -Force -Path $reg | Out-Null
        foreach ($f in $fonts) {
            [void][Win32.FontApi]::AddFontResourceW($f.FullName)
            Set-ItemProperty -Path $reg -Name $f.Name -Value (Join-Path $fontDir $f.Name)
        }
        [void][Win32.FontApi]::SendMessage([IntPtr]0xffff, 0x001D, [IntPtr]::Zero, [IntPtr]::Zero)
        Write-Ok "字体已安装到 $fontDir"
    } catch {
        Write-Warn "字体文件已复制到 $fontDir，但注册失败：$($_.Exception.Message)"
        Write-Warn '如提示符图标显示为方块，请手动双击字体文件安装后重开 WezTerm。'
    }
    Remove-Item -Recurse -Force $extract -ErrorAction SilentlyContinue
    Remove-Item -Force $zip -ErrorAction SilentlyContinue
}

# ============================================================
# 0. 环境检查
# ============================================================
if (-not $IsWindows) { throw '本脚本仅支持 Windows。' }
Write-Host 'Windows 11 终端配置安装程序' -ForegroundColor Magenta
Write-Host "仓库：$RepoRoot" -ForegroundColor DarkGray
if ($DryRun) { Write-Host '*** DryRun 模式：只显示计划，不修改系统 ***' -ForegroundColor Yellow }

# ============================================================
# 1. 依赖
# ============================================================
Write-Step '1/6 检查并安装依赖（winget）'
Ensure-Package -Id 'WezTerm.WezTerm' -Command 'wezterm' -Name 'WezTerm'
Ensure-Package -Id 'Nushell.Nushell' -Command 'nu' -Name 'Nushell'
Ensure-Package -Id 'Starship.Starship' -Command 'starship' -Name 'Starship'
Ensure-Package -Id 'Neovim.Neovim' -Command 'nvim' -Name 'Neovim'
Refresh-Path

$weztermExe = Find-WezTerm
$nuExe = Find-Nu
if ($weztermExe) { Ensure-UserPath (Split-Path $weztermExe) }
if ($nuExe) { Ensure-UserPath (Split-Path $nuExe) }
$starshipCmd = Get-Command starship -ErrorAction SilentlyContinue
if ($starshipCmd) { Ensure-UserPath (Split-Path $starshipCmd.Source) }
$nvimCmd = Get-Command nvim -ErrorAction SilentlyContinue
if ($nvimCmd) { Ensure-UserPath (Split-Path $nvimCmd.Source) }

if (-not $weztermExe) { Write-Warn '未找到 wezterm.exe；请确认安装完成后重开终端再试。' }
if (-not $nuExe) { Write-Warn '未找到 nu.exe；Nushell 配置仍会被复制，但默认 shell 可能无法启动。' }

# ============================================================
# 2. 字体
# ============================================================
Write-Step '2/6 安装字体（CaskaydiaCove Nerd Font）'
Install-NerdFont

# ============================================================
# 3. WezTerm 配置
# ============================================================
Write-Step '3/6 安装 WezTerm 配置'
$weztermTarget = Join-Path $HOME '.config\wezterm'
Backup-Path $weztermTarget
Copy-Tree (Join-Path $ConfigRoot 'wezterm') $weztermTarget
if (-not $DryRun) {
    # 如果 Nushell 不在 winget 默认路径，自动修正 launch.lua 中的 nu 路径
    $launchFile = Join-Path $weztermTarget 'config\launch.lua'
    $defaultExpr = 'wezterm.home_dir .. "\\AppData\\Local\\Programs\\nu\\bin\\nu.exe"'
    if ($nuExe -and (Test-Path $launchFile)) {
        $expected = Join-Path $HOME 'AppData\Local\Programs\nu\bin\nu.exe'
        $nuFull = (Resolve-Path $nuExe).Path
        if ($nuFull -ne $expected) {
            $content = Get-Content -LiteralPath $launchFile -Raw
            if ($content.Contains($defaultExpr)) {
                $content = $content.Replace($defaultExpr, '"' + $nuFull.Replace('\', '\\') + '"')
                Set-Content -LiteralPath $launchFile -Value $content -Encoding utf8
                Write-Info "launch.lua 中 nu 路径已改为：$nuFull"
            }
        }
    }
}
Write-Ok "WezTerm 配置已安装到 $weztermTarget"

# ============================================================
# 4. Starship 配置
# ============================================================
Write-Step '4/6 安装 Starship 配置'
$starshipTarget = Join-Path $HOME '.config\starship.toml'
Backup-Path $starshipTarget
if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path (Split-Path $starshipTarget) | Out-Null
    Copy-Item (Join-Path $ConfigRoot 'starship.toml') $starshipTarget -Force
}
Write-Ok "Starship 配置已安装到 $starshipTarget"

# ============================================================
# 5. Nushell 配置与补全
# ============================================================
Write-Step '5/6 安装 Nushell 配置与补全'
$nuTarget = Join-Path $env:APPDATA 'nushell'
if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $nuTarget | Out-Null }
foreach ($name in @('config.nu', 'env.nu')) {
    $target = Join-Path $nuTarget $name
    Backup-Path $target
    if (-not $DryRun) { Copy-Item (Join-Path $ConfigRoot "nushell\$name") $target -Force }
}
$completionsTarget = Join-Path $nuTarget 'custom-completions'
Backup-Path $completionsTarget
Copy-Tree (Join-Path $ConfigRoot 'nushell\custom-completions') $completionsTarget
Write-Ok "Nushell 配置已安装到 $nuTarget"

# ============================================================
# 6. 可选：Windows 11 一级右键菜单
# ============================================================
if ($WithContextMenu) {
    Write-Step '6/6 安装 Windows 11 一级右键菜单（可选）'
    $ctxScript = Join-Path $PSScriptRoot 'context-menu\install.ps1'
    $ctxArgs = @()
    if ($weztermExe) {
        $gui = Join-Path (Split-Path $weztermExe) 'wezterm-gui.exe'
        if (Test-Path -LiteralPath $gui) { $ctxArgs += @('-WezTermGuiPath', $gui) }
    }
    if ($NoRestartExplorer) { $ctxArgs += '-NoRestartExplorer' }
    if ($DryRun) { Write-Info "会运行：$ctxScript $($ctxArgs -join ' ')" }
    else { & $ctxScript @ctxArgs }
} else {
    Write-Step '6/6 跳过 Windows 11 右键菜单（可选，使用 -WithContextMenu 开启）'
}

# ============================================================
# 校验
# ============================================================
if (-not $DryRun) {
    Write-Step '校验配置'
    if ($weztermExe) {
        $out = & $weztermExe --config-file (Join-Path $weztermTarget 'wezterm.lua') show-keys 2>&1 | Out-String
        if ($out -match 'ERROR|WARN') { Write-Warn 'WezTerm 配置加载出现告警/错误，请运行 scripts/verify.ps1 排查。' }
        else { Write-Ok 'WezTerm 配置可加载' }
    }
    if ($nuExe) {
        $out = & $nuExe --config (Join-Path $nuTarget 'config.nu') -c 'print "nu-config-ok"' 2>&1 | Out-String
        if ($out -match 'nu-config-ok') { Write-Ok 'Nushell 配置可加载' }
        else { Write-Warn 'Nushell 配置加载异常，请运行 scripts/verify.ps1 排查。' }
    }
}

Write-Host ''
Write-Host '安装完成。' -ForegroundColor Green
Write-Host '建议：关闭所有旧 WezTerm 窗口，新开一个 WezTerm 窗口即可看到新配置。' -ForegroundColor DarkGray
Write-Host "健康检查：pwsh -File `"$RepoRoot\scripts\verify.ps1`"" -ForegroundColor DarkGray
if (-not $WithContextMenu) {
    Write-Host '可选：安装 Windows 11 一级右键菜单 → pwsh -File .\scripts\context-menu\install.ps1' -ForegroundColor DarkGray
}
