<#
.SYNOPSIS
    Builds a Retro Rewind WBFS for Wii U Virtual Console (UWUVCI) injection.

.DESCRIPTION
    Inputs (put them in the input folder):
      - A clean Mario Kart Wii USA (RMCE01) image: .iso, .wbfs, .wdf, .wia or .ciso
      - The Retro Rewind pack folder "RetroRewind6" (from https://rwfc.net/downloads)
      - Optional, in input\save: your old save (rksys.dat, banner.bin) and VR
        (RRRating.pul). They are packed into the disc and imported on first boot.

    Output: output\Mario Kart Retro Rewind WiiVC [RMCETO].wbfs, plus output\sd-card
    (a fallback copy of the save files and the VR import homebrew).

    The only requirement is Wiimms ISO Tools (https://wit.wiimm.de).
    Written for Windows PowerShell 5.1, which ships with Windows.
#>
[CmdletBinding()]
param(
    [string]$Image,
    [string]$Pack,
    [string]$Name = 'Mario Kart Retro Rewind WiiVC',
    [string]$Save,
    [switch]$KeepWork,
    [switch]$RebuildLoader
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$InputDir = Join-Path $Root 'input'
$OutputDir = Join-Path $Root 'output'
$KitDir = Join-Path $Root 'kit'
$LoaderDir = Join-Path $Root 'loader'
$WorkDir = Join-Path $Root 'work'
$DiscDir = Join-Path $WorkDir 'workdir.tmp'
$SaveDir = Join-Path $InputDir 'save'
$SdCardSource = Join-Path $Root 'sd-card'

# The inject's TMD ID (see the wit copy below). Its NAND save lives in this title's data folder.
$SaveTitleId = 'RMCR'

# Clean Mario Kart Wii USA main.dol. The bootstrap uses NTSC-U addresses.
$CleanDolHash = 'D2BEEC1B1645FCD134EFE9E7E63774B546667764ED8D431029DACCD725995694'

# Bootstrap layout (see loader\src\linker.ld) and the hooks that jump into it.
# Both slots are loaded as text sections.
$MainAddress = 0x80002600; $MainLimit = 0xA00
$LowAddress = 0x80001C00; $LowLimit = 0x770
$HookPatches = @('802417DC=4BDC0E24', '8000A3B4=4BFF824C')

# Code.pul words checked by the loader before it patches the online salt (error 20911).
$SaltSignature = [ordered]@{
    0x33F88 = '4BFFFD01'; 0x33F90 = '40820014'; 0x33F98 = '3800AE51'
    0x333D0 = '9421FFE0'; 0x3349C = '9421FFE0'
}

function Step([string]$Text) { Write-Host ''; Write-Host "==> $Text" -ForegroundColor Cyan }
function Fail([string]$Text) { throw $Text }

function Find-Wit {
    $cmd = Get-Command wit -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($candidate in @("$env:ProgramFiles\Wiimm\WIT\wit.exe", "${env:ProgramFiles(x86)}\Wiimm\WIT\wit.exe")) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate }
    }
    Fail 'Wiimms ISO Tools (wit) is not installed. Install it from https://wit.wiimm.de, restart the PC, then run the build again.'
}

function Invoke-Wit([string[]]$Arguments) {
    & $script:Wit @Arguments
    if ($LASTEXITCODE -ne 0) { Fail "wit $($Arguments[0]) failed (exit code $LASTEXITCODE)." }
}

function Find-Image {
    if ($Image) {
        if (-not (Test-Path -LiteralPath $Image)) { Fail "Image not found: $Image" }
        return (Resolve-Path -LiteralPath $Image).Path
    }
    $all = @(Get-ChildItem -LiteralPath $InputDir -File -ErrorAction SilentlyContinue)
    $unsupported = @($all | Where-Object { $_.Extension -in '.rvz', '.nkit', '.gcz' -or $_.Name -like '*.nkit.*' })
    $images = @($all | Where-Object { $_.Extension -in '.iso', '.wbfs', '.wdf', '.wia', '.ciso' -and $_.Name -notlike '*.nkit.*' })
    if ($images.Count -eq 0) {
        if ($unsupported.Count) {
            Fail "$($unsupported[0].Name) is not supported by wit. In Dolphin, right-click the game > Convert File... > ISO, and put the .iso in the input folder."
        }
        Fail 'No Mario Kart Wii image in the input folder. Put a Mario Kart Wii USA .iso or .wbfs there.'
    }
    if ($images.Count -gt 1) {
        Fail ("More than one disc image in the input folder; keep only the Mario Kart Wii USA one:`n  " + ($images.Name -join "`n  "))
    }
    return $images[0].FullName
}

function Find-Pack {
    if ($Pack) { $candidates = @(Get-Item -LiteralPath $Pack) }
    else {
        # Accept input\RetroRewind6 or a pack extracted one or two folders deeper.
        $candidates = @(Get-ChildItem -LiteralPath $InputDir -Directory -Recurse -Depth 2 -Filter 'RetroRewind6' -ErrorAction SilentlyContinue)
    }
    foreach ($dir in $candidates) {
        if (Test-Path -LiteralPath (Join-Path $dir.FullName 'Binaries\Code.pul')) { return $dir.FullName }
    }
    Fail 'Retro Rewind pack not found. Extract the pack from https://rwfc.net/downloads and put the "RetroRewind6" folder in the input folder.'
}

function Read-Hex32([byte[]]$Bytes, [int]$Offset) {
    return ('{0:X2}{1:X2}{2:X2}{3:X2}' -f $Bytes[$Offset], $Bytes[$Offset + 1], $Bytes[$Offset + 2], $Bytes[$Offset + 3])
}

function Read-BE32([byte[]]$Bytes, [int]$Offset) {
    return [Convert]::ToInt64((Read-Hex32 $Bytes $Offset), 16)
}

# Returns $true when the NTSC-U section matches the loader's salt patch signature.
function Test-CodePul([string]$Path) {
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 16) { Fail "Code.pul is too small: $Path" }
    $palSize = Read-BE32 $bytes 0
    $usaSize = Read-BE32 $bytes 4
    $usa = 16 + $palSize
    if ($usaSize -lt 32 -or $usa + $usaSize -gt $bytes.Length) { Fail 'Code.pul has no valid USA (NTSC-U) section.' }
    if ((Read-Hex32 $bytes $usa) -ne '4B616D65') { Fail 'Code.pul is corrupt (bad Kamek header).' }
    $codeSize = Read-BE32 $bytes ($usa + 12)
    foreach ($entry in $SaltSignature.GetEnumerator()) {
        if ($entry.Key + 4 -gt $codeSize) { return $false }
        if ((Read-Hex32 $bytes ($usa + 32 + $entry.Key)) -ne $entry.Value) { return $false }
    }
    return $true
}

# Finds rksys.dat, banner.bin and RRRating.pul in input\save (any subfolder).
function Find-SaveFiles {
    $dir = if ($Save) { $Save } else { $SaveDir }
    $found = [ordered]@{}
    if (-not (Test-Path -LiteralPath $dir)) { return $found }
    foreach ($name in @('rksys.dat', 'banner.bin', 'RRRating.pul')) {
        $hits = @(Get-ChildItem -LiteralPath $dir -File -Recurse -Filter $name -ErrorAction SilentlyContinue)
        if ($hits.Count -gt 1) {
            Fail ("More than one $name in $dir; keep only the one you want:`n  " + ($hits.FullName -join "`n  "))
        }
        if ($hits.Count) { $found[$name] = $hits[0].FullName }
    }
    if ($found.Contains('banner.bin') -and -not $found.Contains('rksys.dat')) {
        Fail 'input\save has banner.bin but no rksys.dat. Add rksys.dat or remove banner.bin.'
    }
    if ($found.Contains('rksys.dat')) {
        $bytes = [IO.File]::ReadAllBytes($found['rksys.dat'])
        if ($bytes.Length -lt 4 -or [Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'RKSD') {
            Fail "$($found['rksys.dat']) is not a Mario Kart Wii save (rksys.dat)."
        }
    }
    if ($found.Contains('RRRating.pul')) {
        $bytes = [IO.File]::ReadAllBytes($found['RRRating.pul'])
        if ($bytes.Length -lt 8 -or (Read-Hex32 $bytes 0) -ne '52525254' -or $bytes[4] -ne 0 -or $bytes[5] -ne 1) {
            Fail "$($found['RRRating.pul']) is not a Retro Rewind VR file (RRRating.pul)."
        }
    }
    return $found
}

# Pulsar's mod folder, e.g. /RetroRewind6, from ConfigRT.pul.
function Get-ModFolder([string]$PackDir) {
    $config = Join-Path $PackDir 'Binaries\ConfigRT.pul'
    if (Test-Path -LiteralPath $config) {
        $bytes = [IO.File]::ReadAllBytes($config)
        if ($bytes.Length -gt 0x14 -and $bytes[0x14] -eq [byte][char]'/') {
            $end = [Array]::IndexOf($bytes, [byte]0, 0x14)
            if ($end -gt 0x15) { return [Text.Encoding]::ASCII.GetString($bytes, 0x14, $end - 0x14) }
        }
    }
    return '/RetroRewind6'
}

function Write-Ascii([byte[]]$Buffer, [int]$Offset, [string]$Text, [int]$Max) {
    $b = [Text.Encoding]::ASCII.GetBytes($Text)
    if ($b.Length -ge $Max) { Fail "Path too long for the save bundle: $Text" }
    [Array]::Copy($b, 0, $Buffer, $Offset, $b.Length)
}

function Write-BE32([byte[]]$Buffer, [int]$Offset, [long]$Value) {
    for ($i = 0; $i -lt 4; ++$i) { $Buffer[$Offset + $i] = [byte](($Value -shr (24 - 8 * $i)) -band 0xFF) }
}

# Writes the bundle read by import_save_bundle() in loader\src\bootstrap.c. Layout
# (big-endian): 'RRVC', version 1, id, count, 16 pad bytes; marker[64]; dirs[2][64];
# 4 entries of path[64], backup[64], offset, size, kind (0 replace, 1 merge VR), 20 pad bytes.
function Write-SaveBundle($Files, [string]$ModFolder, [string]$Path) {
    $titleHex = ([Text.Encoding]::ASCII.GetBytes($SaveTitleId) | ForEach-Object { '{0:x2}' -f $_ }) -join ''
    $titleData = "/title/00010000/$titleHex/data"
    $shared = "/shared2/Pulsar$ModFolder"
    $plan = @()
    if ($Files.Contains('rksys.dat')) { $plan += , @('rksys.dat', "$titleData/rksys.dat", "$shared/WiiVC-backup-rksys.dat", 0) }
    if ($Files.Contains('banner.bin')) { $plan += , @('banner.bin', "$titleData/banner.bin", "$shared/WiiVC-backup-banner.bin", 0) }
    if ($Files.Contains('RRRating.pul')) { $plan += , @('RRRating.pul', "$shared/RRRating.pul", "$shared/WiiVC-backup-RRRating.pul", 1) }

    $headerSize = 864
    $blobs = @(); $offset = $headerSize
    foreach ($item in $plan) {
        $data = [IO.File]::ReadAllBytes($Files[$item[0]])
        $blobs += , @($item, $data, $offset)
        $offset += [int]([Math]::Ceiling($data.Length / 32.0) * 32)
    }
    $buffer = New-Object byte[] $offset

    $sha = [Security.Cryptography.SHA256]::Create()
    foreach ($blob in $blobs) { [void]$sha.TransformBlock($blob[1], 0, $blob[1].Length, $null, 0) }
    [void]$sha.TransformFinalBlock((New-Object byte[] 0), 0, 0)
    $id = [Convert]::ToInt64((Read-Hex32 $sha.Hash 0), 16)
    if ($id -eq 0) { $id = 1 }

    Write-Ascii $buffer 0 'RRVC' 5
    Write-BE32 $buffer 4 1
    Write-BE32 $buffer 8 $id
    Write-BE32 $buffer 12 $blobs.Count
    Write-Ascii $buffer 32 "$shared/WiiVCImport.id" 64
    Write-Ascii $buffer 96 '/shared2/Pulsar' 64
    Write-Ascii $buffer 160 $shared 64
    for ($i = 0; $i -lt $blobs.Count; ++$i) {
        $item = $blobs[$i][0]; $data = $blobs[$i][1]; $at = 224 + 160 * $i
        Write-Ascii $buffer $at $item[1] 64
        Write-Ascii $buffer ($at + 64) $item[2] 64
        Write-BE32 $buffer ($at + 128) $blobs[$i][2]
        Write-BE32 $buffer ($at + 132) $data.Length
        Write-BE32 $buffer ($at + 136) $item[3]
        [Array]::Copy($data, 0, $buffer, $blobs[$i][2], $data.Length)
    }
    [IO.File]::WriteAllBytes($Path, $buffer)
    return $id
}

function Remove-WorkDir {
    if (-not (Test-Path -LiteralPath $WorkDir)) { return }
    # Unlink the junctions first so the recursive delete can never reach input or kit.
    foreach ($link in @(Get-ChildItem -LiteralPath $WorkDir -Force | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint })) {
        cmd.exe /c "rmdir `"$($link.FullName)`"" | Out-Null
    }
    if (@(Get-ChildItem -LiteralPath $WorkDir -Force | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count) {
        Fail "Could not unlink the folders in $WorkDir; delete it by hand."
    }
    Remove-Item -LiteralPath $WorkDir -Recurse -Force
}

function Restore-PackNames([string]$PackDir) {
    # copy-files.bat temporarily renames these; put them back if it was interrupted.
    $lang = Join-Path $PackDir 'Language'
    foreach ($pair in @(@('SPAEU', 'SPA(EU)'), @('SPANTSC', 'SPA(NTSC)'))) {
        $from = Join-Path $lang $pair[0]
        if ((Test-Path -LiteralPath $from) -and -not (Test-Path -LiteralPath (Join-Path $lang $pair[1]))) {
            Rename-Item -LiteralPath $from -NewName $pair[1]
        }
    }
}

$packDir = $null
try {
    Write-Host 'Retro Rewind WiiVC builder' -ForegroundColor Green

    Step 'Checking requirements'
    $script:Wit = Find-Wit
    Write-Host "wit:  $script:Wit"
    $imagePath = Find-Image
    Write-Host "Disc: $imagePath"
    $packDir = Find-Pack
    Write-Host "Pack: $packDir"
    foreach ($needed in @('copy-files.bat', 'extra', 'Patches')) {
        if (-not (Test-Path -LiteralPath (Join-Path $KitDir $needed))) { Fail "The kit folder is missing $needed." }
    }

    if ($RebuildLoader) {
        Step 'Rebuilding the bootstrap (WSL Ubuntu-24.04 with powerpc-linux-gnu-gcc)'
        $linuxSrc = (& wsl.exe -d Ubuntu-24.04 -- wslpath -a (Join-Path $LoaderDir 'src')).Trim()
        & wsl.exe -d Ubuntu-24.04 -- sh -lc "cd '$linuxSrc' && ./build.sh"
        if ($LASTEXITCODE -ne 0) { Fail 'Bootstrap build failed.' }
    }
    $mainBin = Join-Path $LoaderDir 'prebuilt\bootstrap-main.bin'
    $lowBin = Join-Path $LoaderDir 'prebuilt\bootstrap-low.bin'
    foreach ($bin in @($mainBin, $lowBin)) { if (-not (Test-Path -LiteralPath $bin)) { Fail "Missing $bin" } }
    $mainSize = (Get-Item -LiteralPath $mainBin).Length
    $lowSize = (Get-Item -LiteralPath $lowBin).Length
    if ($mainSize -gt $MainLimit -or $lowSize -gt $LowLimit) { Fail 'The prebuilt bootstrap does not fit its memory slots.' }

    $saveFiles = Find-SaveFiles
    if ($saveFiles.Count) {
        Write-Host 'Save:'
        foreach ($f in $saveFiles.Values) { Write-Host "  $f" }
    }
    else { Write-Host 'Save: none (put old save files in input\save to import them)' }

    $codePul = Join-Path $packDir 'Binaries\Code.pul'
    $saltOk = Test-CodePul $codePul
    if ($saltOk) { Write-Host 'Code.pul: supported (online fix will apply)' }
    else {
        Write-Warning ('This Code.pul is a different Retro Rewind version than the loader was made for. ' +
            'The game should still boot, but online may fail with error 20911 until the offsets in loader\src\bootstrap.c are updated.')
    }

    Step 'Extracting Mario Kart Wii'
    Remove-WorkDir
    New-Item -ItemType Directory -Path $WorkDir | Out-Null
    Invoke-Wit @('extract', $imagePath, '--DEST', $DiscDir, '--psel', 'data', '--links', '--include', 'RMCE01', '-vv1')
    $dol = Join-Path $DiscDir 'sys\main.dol'
    if (-not (Test-Path -LiteralPath $dol)) {
        Fail 'The disc image is not Mario Kart Wii USA (RMCE01). Only the USA version is supported.'
    }
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $dol).Hash -ne $CleanDolHash) {
        Fail 'The disc is Mario Kart Wii USA, but its main.dol is modified. Use a clean, unmodified dump.'
    }

    Step 'Adding Retro Rewind files'
    New-Item -ItemType Junction -Path (Join-Path $WorkDir 'RetroRewind6') -Target $packDir | Out-Null
    New-Item -ItemType Junction -Path (Join-Path $WorkDir 'extra') -Target (Join-Path $KitDir 'extra') | Out-Null
    New-Item -ItemType Junction -Path (Join-Path $WorkDir 'Patches') -Target (Join-Path $KitDir 'Patches') | Out-Null
    $settings = @{
        GAMEID = 'RMCE01'; REGION = 'E'; BASEVER = 'USA'; NAND = 'RetroWFC'; PCTRACK = 'RetroRewind'
        PLG = 'Language'; PCONFIG = 'pconfig'; PATCHES = 'wvc'; SAVEPIC = 'Replace'; THP = 'Replace'
        SPLT = '--split'; LANGUAGE = 'English'
    }
    foreach ($key in $settings.Keys) { Set-Item -Path "Env:$key" -Value $settings[$key] }
    $log = Join-Path $WorkDir 'copy-files.log'
    Push-Location -LiteralPath $WorkDir
    try { cmd.exe /c "call `"$(Join-Path $KitDir 'copy-files.bat')`" > `"$log`" 2>&1" }
    finally { Pop-Location; Restore-PackNames $packDir }
    if (-not (Test-Path -LiteralPath (Join-Path $DiscDir 'files\Binaries\Code.pul'))) {
        Fail "Copying the Retro Rewind files failed. See $log"
    }
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $dol).Hash -ne $CleanDolHash) {
        Fail 'copy-files.bat changed main.dol; expected the WiiVC (wvc) setting to leave it clean.'
    }

    Step 'Installing the WiiVC bootstrap'
    $dolArgs = @('dolpatch', $dol,
        ('NEW=TEXT,0x{0:X},0x{1:x}' -f $MainAddress, $mainSize), ('LOAD=0x{0:X},{1}' -f $MainAddress, $mainBin),
        ('NEW=TEXT,0x{0:X},0x{1:x}' -f $LowAddress, $lowSize), ('LOAD=0x{0:X},{1}' -f $LowAddress, $lowBin)) + $HookPatches
    Invoke-Wit $dolArgs

    if ($saveFiles.Count) {
        Step 'Packing your save for import on first boot'
        $modFolder = Get-ModFolder $packDir
        $bundle = Join-Path $DiscDir 'files\WiiVC\SaveImport.bin'
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $bundle) | Out-Null
        $bundleId = Write-SaveBundle $saveFiles $modFolder $bundle
        Write-Host ('Bundle ID {0:X8}; the game imports it once and backs up the old files to /shared2/Pulsar{1}' -f $bundleId, $modFolder)
    }

    Step 'Packing the WBFS'
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    $dest = Join-Path $OutputDir '$X'
    Invoke-Wit @('-E$', 'copy', $DiscDir, '-T0', '--DEST', $dest, '-ovv', '--links',
        '--id', 'RMCETO', '--ticket-id=RMCR', '--tmd-id=RMCR', '--boot-id=RMCE',
        '--security-fix', '--name', $Name, '--wbfs', '--split')
    $wbfs = Get-ChildItem -LiteralPath $OutputDir -Filter '*RMCETO*.wbfs' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $wbfs) { Fail 'wit did not produce a WBFS file.' }

    Step 'Verifying'
    Invoke-Wit @('verify', '--long', $wbfs.FullName)

    Step 'Preparing the SD card fallback'
    $sdOut = Join-Path $OutputDir 'sd-card'
    if (Test-Path -LiteralPath $sdOut) { Remove-Item -LiteralPath $sdOut -Recurse -Force }
    Copy-Item -LiteralPath $SdCardSource -Destination $sdOut -Recurse
    if ($saveFiles.Contains('RRRating.pul')) { Copy-Item -LiteralPath $saveFiles['RRRating.pul'] -Destination $sdOut }
    $saveCopies = @($saveFiles.Keys | Where-Object { $_ -ne 'RRRating.pul' })
    if ($saveCopies.Count) {
        $saveOut = Join-Path $sdOut 'RetroRewind save backup'
        New-Item -ItemType Directory -Path $saveOut | Out-Null
        foreach ($key in $saveCopies) { Copy-Item -LiteralPath $saveFiles[$key] -Destination $saveOut }
    }
    Write-Host "  $sdOut"

    if (-not $KeepWork) { Remove-WorkDir }

    Write-Host ''
    Write-Host 'Build complete:' -ForegroundColor Green
    Write-Host "  $($wbfs.FullName)"
    Write-Host ''
    Write-Host 'Inject it with UWUVCI AIO (Wii):'
    Write-Host '  - Use GamePad as: Classic Controller'
    Write-Host '  - Leave "Disable GamePad" unchecked (keeps the picture on the GamePad)'
    Write-Host '  - Give it its own title ID if another Retro Rewind inject is installed'
    if ($saveFiles.Count) {
        Write-Host ''
        Write-Host 'Your save is inside the image and is imported the first time the game starts.'
        Write-Host 'If that fails, output\sd-card has the same files and the RR VR Import homebrew.'
    }
    if (-not $saltOk) { Write-Warning 'Remember: online may show error 20911 with this Code.pul version.' }
}
catch {
    Write-Host ''
    Write-Host "BUILD FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($packDir) { try { Restore-PackNames $packDir } catch {} }
    Write-Host "Temporary files were left in $WorkDir; the next build clears them."
    exit 1
}
