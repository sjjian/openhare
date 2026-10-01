# Build script for Windows Flutter application
# Usage: powershell -ExecutionPolicy Bypass -File .\windows_build.ps1

$ErrorActionPreference = "Stop"

# Configuration
$InnoCompiler = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$InnoScriptName = "windows_setup.iss"

# Path configuration
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PubspecPath = Join-Path $ProjectRoot "client\pubspec.yaml"

function Resolve-VCLibsPath {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (!(Test-Path $vswhere)) {
        throw "vswhere.exe not found at: $vswhere"
    }

    $vsRoot = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($vsRoot)) {
        throw "Visual Studio C++ toolset not found"
    }

    $redistRoot = Join-Path $vsRoot.Trim() "VC\Redist\MSVC"
    $candidates = Get-ChildItem -Path $redistRoot -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    foreach ($dir in $candidates) {
        $crt = Join-Path $dir.FullName "x64\Microsoft.VC143.CRT"
        if (Test-Path (Join-Path $crt "vcruntime140.dll")) {
            return $crt
        }
    }

    throw "Microsoft.VC143.CRT not found under $redistRoot"
}

$VCLibsPath = Resolve-VCLibsPath
Write-Host "Using VC runtime: $VCLibsPath" -ForegroundColor Green

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Flutter Windows Application" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Read version from pubspec.yaml for Inno Setup
if (!(Test-Path $PubspecPath)) {
    Write-Host "ERROR: pubspec.yaml not found at: $PubspecPath" -ForegroundColor Red
    exit 1
}

$PubspecContent = Get-Content -Path $PubspecPath -Raw
$VersionMatch = [regex]::Match($PubspecContent, '(?m)^\s*version:\s*([^\s#]+)')

if (!$VersionMatch.Success) {
    Write-Host "ERROR: Failed to parse version from pubspec.yaml" -ForegroundColor Red
    exit 1
}

$AppVersion = $VersionMatch.Groups[1].Value.Trim()
$AppVersion = $AppVersion.Trim("'")
$AppVersion = $AppVersion.Trim('"')
# Installer version matches the release tag: v0.13.0 <-> 0.13.0 or 0.13.0+1.
$AppVersion = ($AppVersion -split '\+', 2)[0]
Write-Host "Detected app version: $AppVersion" -ForegroundColor Green
Write-Host ""

# Build Flutter app
Write-Host "[1/2] Building Flutter Windows app (release)..." -ForegroundColor Yellow
$ClientPath = Join-Path $ProjectRoot "client"

Push-Location $ClientPath
try {
    flutter build windows --release
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Flutter build failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Flutter build completed successfully." -ForegroundColor Green
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "[2/2] Creating installer with Inno Setup..." -ForegroundColor Yellow

# Compile Inno Setup script with path definitions
$InnoScript = Join-Path $ProjectRoot $InnoScriptName

# Pass path definitions to Inno Setup compiler
$InnoArgs = @(
    "/DProjectRoot=$ProjectRoot"
    "/DVCLibsPath=$VCLibsPath"
    "/DMyAppVersion=$AppVersion"
    $InnoScript
)

& $InnoCompiler @InnoArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Inno Setup compilation failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installer created in: $ProjectRoot" -ForegroundColor Green
Write-Host ""

