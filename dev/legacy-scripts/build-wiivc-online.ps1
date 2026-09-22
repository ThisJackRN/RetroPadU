[CmdletBinding()]
param([string]$OutputDirectory = (Join-Path $PSScriptRoot 'build\wiivc-online-image-new'))
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$workDir = Join-Path $root 'ioso\workdir.tmp'
$sourceDol = Join-Path $workDir 'sys\main.dol'
$loaderDir = Join-Path $root 'wiivc-loader'
$loaderText = Join-Path $loaderDir 'build\bootstrap-text.bin'
$loaderData = Join-Path $loaderDir 'build\bootstrap-data.bin'
$patchedDir = Join-Path $root 'build\wiivc-online'
$patchedDol = Join-Path $patchedDir 'main.dol'
$backupDol = Join-Path $patchedDir 'clean-main.dol'
$codePul = Join-Path $root 'ioso\RetroRewind6\Binaries\Code.pul'
$expectedCleanHash = 'D2BEEC1B1645FCD134EFE9E7E63774B546667764ED8D431029DACCD725995694'

foreach ($file in @($sourceDol, $codePul, (Join-Path $loaderDir 'build.sh'))) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Missing: $file" }
}
if (Test-Path -LiteralPath $OutputDirectory) { throw "Output already exists: $OutputDirectory" }
$cleanHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceDol).Hash
if ($cleanHash -ne $expectedCleanHash) { throw "Unexpected clean DOL hash: $cleanHash" }

$linuxLoaderDir = (& wsl.exe -d Ubuntu-24.04 -- wslpath -a $loaderDir).Trim()
& wsl.exe -d Ubuntu-24.04 -- sh -lc "cd '$linuxLoaderDir' && ./build.sh"
if ($LASTEXITCODE) { throw 'Bootstrap build failed.' }
& py (Join-Path $root 'tools\validate_code_pul.py') $codePul
if ($LASTEXITCODE) { throw 'Code.pul validation failed.' }

New-Item -ItemType Directory -Path $patchedDir -Force | Out-Null
Copy-Item -LiteralPath $sourceDol -Destination $backupDol -Force
Copy-Item -LiteralPath $sourceDol -Destination $patchedDol -Force
$textHex = '{0:x}' -f (Get-Item -LiteralPath $loaderText).Length
$dataHex = '{0:x}' -f (Get-Item -LiteralPath $loaderData).Length
& wit dolpatch $patchedDol "NEW=TEXT,0x80002600,0x$textHex" "LOAD=0x80002600,$loaderText" "NEW=DATA,0x80001C00,0x$dataHex" "LOAD=0x80001C00,$loaderData" 802417DC=4BDC0E24 8000A3B4=4BFF824C
if ($LASTEXITCODE) { throw 'DOL patch failed.' }

try {
    Copy-Item -LiteralPath $patchedDol -Destination $sourceDol -Force
    $destination = Join-Path $OutputDirectory '$X'
    & wit '-E$' copy $workDir -T0 --DEST $destination -ovv --links --id RMCETO --ticket-id=RMCR --tmd-id=RMCR --boot-id=RMCE --security-fix --name 'Mario Kart Retro Rewind WiiVC Online Test' --wbfs --split
    if ($LASTEXITCODE) { throw 'WBFS packaging failed.' }
}
finally {
    Copy-Item -LiteralPath $backupDol -Destination $sourceDol -Force
}
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourceDol).Hash -ne $cleanHash) {
    throw 'Clean DOL restoration failed.'
}
$image = Get-ChildItem -LiteralPath $OutputDirectory -Filter '*.wbfs' | Select-Object -First 1
& wit verify --long $image.FullName
if ($LASTEXITCODE) { throw 'WBFS verification failed.' }
Write-Host "Build complete: $($image.FullName)"
