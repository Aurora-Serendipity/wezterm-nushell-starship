#requires -Version 7.0
<#
.SYNOPSIS
    安装/修复 Windows 11 一级右键菜单项 "Open WezTerm here"。

.DESCRIPTION
    Windows 11 的新右键菜单只接受带包身份的 IExplorerCommand 扩展，
    WezTerm 安装器写入的经典注册表项只能出现在"显示更多选项"里。
    本脚本使用 LGPL-3.0 开源工具 Custom Context Menu
    （https://github.com/ikas-mc/ContextMenuForWindows11）的开发者包做用户级松散注册，
    把 "Open WezTerm here" 提升到一级菜单。无需管理员权限，但需要开发者模式。

.PARAMETER WezTermGuiPath
    wezterm-gui.exe 的完整路径；不填时自动探测。

.PARAMETER PackageDir
    已解压的 DEV 包目录（离线/复用），填了则跳过下载。

.PARAMETER NoRestartExplorer
    安装完成后不自动重启资源管理器。
#>
[CmdletBinding()]
param(
    [string]$WezTermGuiPath = '',
    [string]$PackageDir = '',
    [switch]$NoRestartExplorer
)

$ErrorActionPreference = 'Stop'

$packageName = '91b3cc93-5e27-4b3e-9d97-dd137b7fb3ea'
$releaseTag  = '5.9.0.2'
$zipName     = 'ContextMenuCustom-CMC_DEV_RELEASE-x64.zip'
$zipUrl      = "https://github.com/ikas-mc/ContextMenuForWindows11/releases/download/$releaseTag/$zipName"
$stableDir   = Join-Path $env:LOCALAPPDATA 'Programs\ContextMenuCustomDev'
$workDir     = Join-Path $env:TEMP 'cm4w11-install'

function Find-WezTermGui {
    param([string]$Override)
    if ($Override) {
        if (Test-Path -LiteralPath $Override) { return (Resolve-Path -LiteralPath $Override).Path }
        throw "找不到 wezterm-gui.exe：$Override"
    }
    $cmd = Get-Command wezterm -ErrorAction SilentlyContinue
    if ($cmd) {
        $candidate = Join-Path (Split-Path $cmd.Source) 'wezterm-gui.exe'
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    foreach ($p in @(
            (Join-Path $env:LOCALAPPDATA 'Programs\WezTerm\wezterm-gui.exe'),
            (Join-Path $env:ProgramFiles 'WezTerm\wezterm-gui.exe'))) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    throw '找不到 wezterm-gui.exe，请用 -WezTermGuiPath 指定。'
}

# ---------- 0. 前置检查 ----------
if (-not $IsWindows) { throw '仅支持 Windows。' }
$devMode = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
if ($devMode -ne 1) {
    throw '需要先开启开发者模式：设置 > 系统 > 开发者选项 > 开发人员模式。'
}
$weztermGui = Find-WezTermGui -Override $WezTermGuiPath
Write-Host "WezTerm: $weztermGui" -ForegroundColor DarkGray

# ---------- 1. 准备包源 ----------
if ($PackageDir) {
    if (-not (Test-Path -LiteralPath (Join-Path $PackageDir 'AppxManifest.xml'))) {
        throw "PackageDir 里没有 AppxManifest.xml：$PackageDir"
    }
    $sourceDir = (Resolve-Path -LiteralPath $PackageDir).Path
    $useLocal = $true
    Write-Host '[1/5] 使用本地包目录（跳过下载）...' -ForegroundColor Cyan
} else {
    if (Test-Path $workDir) { Remove-Item -Recurse -Force $workDir }
    New-Item -ItemType Directory -Force -Path $workDir | Out-Null
    $zip = Join-Path $workDir $zipName
    Write-Host '[1/5] 下载 Custom Context Menu DEV 包 ...' -ForegroundColor Cyan
    $downloaded = $false
    for ($attempt = 1; $attempt -le 3 -and -not $downloaded; $attempt++) {
        try {
            Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing -TimeoutSec 120
            $downloaded = (Test-Path $zip) -and ((Get-Item $zip).Length -gt 10MB)
        } catch { Write-Warning "第 $attempt 次下载失败：$($_.Exception.Message)" }
        if (-not $downloaded) { Start-Sleep -Seconds 3 }
    }
    if (-not $downloaded) {
        Write-Warning '改用 curl 重试 ...'
        try {
            & curl.exe -L --retry 3 --retry-delay 3 -o $zip $zipUrl
            $downloaded = (Test-Path $zip) -and ((Get-Item $zip).Length -gt 10MB)
        } catch { }
    }
    if (-not $downloaded) { throw 'DEV 包下载失败。可稍后重试，或用 -PackageDir 指定已解压目录。' }
    Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $workDir 'pkg') -Force
    $pkgFolder = Get-ChildItem (Join-Path $workDir 'pkg') -Directory | Select-Object -First 1
    if (-not $pkgFolder) { throw '解压后未找到包目录。' }
    $sourceDir = $pkgFolder.FullName
    $useLocal = $false
}

# ---------- 2. 依赖 ----------
Write-Host '[2/5] 安装依赖（仅当前用户，已安装会跳过）...' -ForegroundColor Cyan
$deps = Join-Path $sourceDir 'Dependencies\x64'
if (Test-Path $deps) {
    foreach ($appx in Get-ChildItem $deps -Filter *.appx) {
        try { Add-AppxPackage -Path $appx.FullName -ErrorAction Stop } catch { Write-Warning "依赖已存在或安装失败：$($appx.Name)" }
    }
} else {
    Write-Host '  （本地包目录无 Dependencies；如依赖已装可忽略）' -ForegroundColor DarkGray
}

# ---------- 3. 松散注册 ----------
Write-Host '[3/5] 注册开发者松散包 ...' -ForegroundColor Cyan
Get-AppxPackage | Where-Object { $_.Name -eq $packageName } | ForEach-Object {
    Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
}
if (Test-Path $stableDir) { Remove-Item -Recurse -Force $stableDir }
New-Item -ItemType Directory -Force -Path $stableDir | Out-Null
if ($useLocal) {
    Copy-Item -Path (Join-Path $sourceDir '*') -Destination $stableDir -Recurse -Force
} else {
    $msix = Get-ChildItem $sourceDir -Filter *.msix | Select-Object -First 1
    if (-not $msix) { throw '未找到 .msix 文件。' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($msix.FullName, $stableDir)
}
Add-AppxPackage -Register (Join-Path $stableDir 'AppxManifest.xml')
Start-Sleep -Seconds 2
$pkg = Get-AppxPackage | Where-Object { $_.Name -eq $packageName }
if (-not $pkg) { throw '包注册失败。' }

# ---------- 4. 菜单配置 ----------
Write-Host '[4/5] 写入菜单配置 ...' -ForegroundColor Cyan
$configDir = Join-Path $env:LOCALAPPDATA "Packages\$($pkg.PackageFamilyName)\LocalState\custom_commands"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
$escaped = $weztermGui.Replace('\', '\\')
$json = @"
{
  "title": "Open WezTerm here",
  "exe": "\"$escaped\"",
  "param": "start --no-auto-connect --cwd \"{path}\"",
  "icon": "\"$escaped\",0",
  "index": 1,
  "acceptDirectoryFlag": 3,
  "acceptFileFlag": 0,
  "acceptExts": "",
  "acceptFileRegex": "",
  "acceptMultipleFilesFlag": 0,
  "showWindowFlag": 0,
  "runAsFlag": 0
}
"@
Set-Content -Path (Join-Path $configDir 'Open WezTerm here.json') -Value $json -Encoding utf8

# 清理旧版本可能写在非包目录下的副本
$legacyConfigDir = Join-Path $env:LOCALAPPDATA 'custom_commands'
if (Test-Path $legacyConfigDir) { Remove-Item -Recurse -Force $legacyConfigDir }

# ---------- 5. 重启资源管理器 ----------
if (-not $NoRestartExplorer) {
    Write-Host '[5/5] 重启资源管理器 ...' -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
    Start-Sleep -Seconds 3
}
Remove-Item -Recurse -Force $workDir -ErrorAction SilentlyContinue

Write-Host ''
Write-Host '完成：右键资源管理器空白处或文件夹，一级菜单中应出现 "Open WezTerm here"。' -ForegroundColor Green
Write-Host "包: $($pkg.PackageFullName)" -ForegroundColor DarkGray
Write-Host "配置: $(Join-Path $configDir 'Open WezTerm here.json')" -ForegroundColor DarkGray
