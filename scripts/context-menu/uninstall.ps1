#requires -Version 7.0
<#
.SYNOPSIS
    卸载 Windows 11 一级右键菜单项 "Open WezTerm here"。

.DESCRIPTION
    移除 Custom Context Menu 开发者包及其菜单配置；
    经典注册表入口（"显示更多选项"里的旧项）不受影响。

.PARAMETER NoRestartExplorer
    卸载完成后不自动重启资源管理器。
#>
[CmdletBinding()]
param(
    [switch]$NoRestartExplorer
)

$ErrorActionPreference = 'Continue'

$packageName = '91b3cc93-5e27-4b3e-9d97-dd137b7fb3ea'
$stableDir   = Join-Path $env:LOCALAPPDATA 'Programs\ContextMenuCustomDev'

Write-Host '移除 Custom Context Menu 包 ...' -ForegroundColor Cyan
Get-AppxPackage | Where-Object { $_.Name -eq $packageName } | ForEach-Object {
    Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
    Write-Host "已移除：$($_.PackageFullName)" -ForegroundColor DarkGray
}

if (Test-Path $stableDir) {
    Remove-Item -Recurse -Force $stableDir -ErrorAction SilentlyContinue
    Write-Host "已删除：$stableDir" -ForegroundColor DarkGray
}

$legacyConfigDir = Join-Path $env:LOCALAPPDATA 'custom_commands'
if (Test-Path $legacyConfigDir) { Remove-Item -Recurse -Force $legacyConfigDir -ErrorAction SilentlyContinue }

if (-not $NoRestartExplorer) {
    Write-Host '重启资源管理器 ...' -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
    Start-Sleep -Seconds 3
}

Write-Host ''
Write-Host '已卸载。经典右键入口（"显示更多选项"中的 Open WezTerm here）仍然可用。' -ForegroundColor Green
