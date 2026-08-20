[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $BinaryPath,

    [Parameter(Position = 1)]
    [string] $InstallDir = (Join-Path $HOME ".local\bin")
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
if (-not $BinaryPath) {
    $BinaryPath = Join-Path $scriptDir "encry.exe"
}

$source = (Resolve-Path -LiteralPath $BinaryPath).Path
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Build file not found: $BinaryPath"
}

$installPath = [System.IO.Path]::GetFullPath($InstallDir)
New-Item -ItemType Directory -Force -Path $installPath | Out-Null
$target = Join-Path $installPath "encry.exe"
Copy-Item -LiteralPath $source -Destination $target -Force

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathEntries = @()
if ($userPath) {
    $pathEntries = $userPath -split ";" | Where-Object { $_ -ne "" }
}

if ($pathEntries -notcontains $installPath) {
    $newUserPath = (($pathEntries + $installPath) -join ";")
    [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    $env:Path = "$installPath;$env:Path"
    Write-Host "PATH was updated for the current user."
}

Write-Host "encry was installed to $target."
Write-Host "Open a new PowerShell window and test with: encry -h"
