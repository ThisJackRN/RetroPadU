<#
.SYNOPSIS
    Packs the files RetroPadU.exe carries inside it (run by gui\build.cmd).

.DESCRIPTION
    The zip holds the build script, the kit, the loader and the SD card homebrew,
    exactly as committed, plus Wiimms ISO Tools from this PC's install, so the exe
    builds images with nothing else installed. Only files tracked by git are packed,
    so game files, saves and other ignored files can never end up in the exe.
#>
param([Parameter(Mandatory)][string]$Out)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

$Root = Split-Path -Parent $PSScriptRoot
$files = [ordered]@{}

$tracked = @(& git -C $Root ls-files -- scripts/build-wiivc.ps1 kit loader/prebuilt sd-card)
if ($LASTEXITCODE -ne 0 -or $tracked.Count -eq 0) { throw 'git ls-files failed. Build the exe from a git checkout of RetroPadU.' }
foreach ($path in $tracked) {
    $source = Join-Path $Root $path
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Tracked file is missing: $path" }
    $files[$path] = $source
}

# wit and the Cygwin DLLs it loads (wit.exe -> cygcrypto, cygncursesw, cygz -> cygwin1).
$wit = Get-Command wit -ErrorAction SilentlyContinue
$witDir = if ($wit) { Split-Path -Parent $wit.Source } else { Join-Path $env:ProgramFiles 'Wiimm\WIT' }
foreach ($name in 'wit.exe', 'cygwin1.dll', 'cygcrypto-1.1.dll', 'cygncursesw-10.dll', 'cygz.dll') {
    $source = Join-Path $witDir $name
    if (-not (Test-Path -LiteralPath $source)) { throw "Wiimms ISO Tools is needed to build the exe; $name was not found in $witDir." }
    $files["tools/wit/$name"] = $source
}
$version = & (Join-Path $witDir 'wit.exe') --version
if ($version -notmatch 'v3\.05a r8638') {
    Write-Warning "Bundling $version; update the version in gui\THIRD-PARTY-NOTICES.txt to match."
}
$files['tools/wit/THIRD-PARTY-NOTICES.txt'] = Join-Path $PSScriptRoot 'THIRD-PARTY-NOTICES.txt'
foreach ($license in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'licenses') -File) {
    $files["tools/wit/licenses/$($license.Name)"] = $license.FullName
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Out) | Out-Null
$stream = [IO.File]::Create($Out)
try {
    $zip = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($entry in $files.GetEnumerator()) {
            [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $entry.Value, $entry.Key, [IO.Compression.CompressionLevel]::Optimal)
        }
    }
    finally { $zip.Dispose() }
}
finally { $stream.Dispose() }
Write-Host ("Packed {0} files ({1:N1} MB)" -f $files.Count, ((Get-Item -LiteralPath $Out).Length / 1MB))
