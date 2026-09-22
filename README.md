# RetroPadU

Builds a Mario Kart Wii **Retro Rewind** disc image that you inject with UWUVCI AIO. The result plays on the Wii U with the GamePad as the controller and screen, and connects to Retro WFC.

> [!WARNING]
> **Beta.** This has been tested on one Wii U. Back up your save data and your SD card before using it, especially before importing an old save. Use at your own risk.
>
> RetroPadU is a fan project, not affiliated with Nintendo or the Retro Rewind team. It contains no game files: you need your own dump of Mario Kart Wii (USA) and the Retro Rewind pack.

## Quick start

1. Install **Wiimms ISO Tools** from <https://wit.wiimm.de>, then restart the PC. This is the only requirement.
2. Put these in `input\` (see `input\PUT FILES HERE.txt`):
   - A clean **Mario Kart Wii USA** (RMCE01) image: `.iso`, `.wbfs`, `.wdf`, `.wia` or `.ciso`.
   - The **`RetroRewind6`** pack folder, extracted from <https://rwfc.net/downloads>.
   - Optional: your old save and VR in **`input\save\`**. See [Bringing your save and VR](#bringing-your-save-and-vr).
3. Double-click **`BUILD.cmd`**.
4. The finished image is `output\Mario Kart Retro Rewind WiiVC [RMCETO].wbfs`. `output\sd-card\` holds the fallback copy for your SD card.

Then inject it with **UWUVCI AIO** (Wii):
- **Use GamePad as:** Classic Controller
- Leave **Disable GamePad** unchecked, so the picture stays on the GamePad
- Give it its own title ID if another Retro Rewind inject is installed

On first launch, if the game says the save data is corrupted and offers to delete it, back out unless you are sure you have no Retro Rewind save. The inject shares the vWii save slot `RMCR` with the Wiimm USB-loader build.

## Folder layout

| Folder | What it is |
| --- | --- |
| `BUILD.cmd` | One-click build. Accepts options, e.g. `BUILD.cmd -KeepWork` |
| `input\` | Your disc image, the `RetroRewind6` pack, and optionally your old save in `input\save\` |
| `output\` | Built WBFS files, plus `output\sd-card\` (fallback save copy and VR import homebrew) |
| `sd-card\` | Source for `output\sd-card\`: the RR VR Import homebrew |
| `scripts\build-wiivc.ps1` | The build script |
| `kit\` | The parts of the Retro Rewind ISO-builder kit the build uses (`copy-files.bat`, `extra\`, `Patches\`, Riivolution XML) |
| `loader\prebuilt\` | The compiled WiiVC bootstrap used by the build |
| `loader\src\` | Bootstrap source, for developers |
| `rrrating-import\` | Source of the VR import homebrew |
| `dev\` | DOL/`Code.pul` inspection tools (need Python and `pip install capstone`) and the legacy build scripts. Not needed to build |

Build options for `scripts\build-wiivc.ps1` (or `BUILD.cmd`):
- `-Image <path>` / `-Pack <path>` / `-Save <path>`: use files outside `input\`.
- `-Name <text>`: the disc title (default `Mario Kart Retro Rewind WiiVC`).
- `-KeepWork`: keep the extracted disc in `work\` for inspection.
- `-RebuildLoader`: recompile the bootstrap first (needs WSL `Ubuntu-24.04` with `powerpc-linux-gnu-gcc`).

## Bringing your save and VR

Retro Rewind keeps your progress in two places:
- **`rksys.dat`** (with `banner.bin`) is the Mario Kart Wii save: licenses, Miis and your Retro WFC profile ID. The Retro Rewind Channel and Riivolution keep it on the SD card in `riivolution\save\RetroWFC\RMCE\` (`RetroWFC2` if "Separate Savegame" was on).
- **`RRRating.pul`** is your VR/BR, keyed by profile ID. It's usually on the SD card at `RetroRewind6\RRRating.pul`.

**Automatic import (recommended).** Copy those files into `input\save\` and build. The files are packed into the disc, and the first time the game starts it:
1. Backs up whatever is already on the console to `/shared2/Pulsar/RetroRewind6/WiiVC-backup-*`.
2. Writes `rksys.dat` and `banner.bin` to the inject's save (title `RMCR`). This **replaces** that save, so leave `rksys.dat` out if the inject already shows your license.
3. Merges `RRRating.pul` by profile ID: your profiles replace the same profiles on the console, and other profiles are kept.
4. Records what it imported, so each file is imported only once. Rebuilding later never resets your VR.

If the console has no save for the inject yet, the save files can't be written on the very first start. Let the game create a save, then restart it, and the import finishes. The VR is imported on the first start either way.

Don't race online on the inject before your VR is imported, because races upload the VR you currently have.

**Fallback: SD card.** Every build also writes `output\sd-card\` with the RR VR Import homebrew, your `RRRating.pul`, and a copy of your save files in `RetroRewind save backup\`. Use it if the automatic import fails:
1. Copy the contents of `output\sd-card\` to the root of your SD card.
2. Run **RR VR Import** from the vWii Homebrew Channel with a Wii Remote or GameCube controller. Check the profiles, then press A. It merges VR by profile ID and backs up the old copy to `sd:/RRRating-vwii-backup.pul`.
3. For `rksys.dat`, use SaveGame Manager GX in vWii (save ID `RMCR`): extract, replace `rksys.dat` in the extracted folder, and restore.

The game logs the import result as `RR WiiVC: save import N`: `0` imported, `1` already done, `-10`/`-11`/`-12` a file that will be retried on the next start.

## How it works

- **Bootstrap.** WiiVC shows a black screen when the Riivolution memory patches overwrite the game code at `0x80004000`. Instead, the build adds a small bootstrap in two free low-memory slots, `0x80002600` and `0x80001C00`, both loaded as code. It points Retro Rewind's DOL and REL loader hooks at it. The bootstrap applies the `RRLoadPack` memory patches (plus `0x800017D8 = 1` for NAND saves, as in the pack's USB-loader DOL) and loads the unmodified `Binaries/Code.pul`.
- **Online (error 20911).** Retro Rewind creates its Retro WFC login salt with `ES_Sign`, which fails in a fake-signed WiiVC inject. After loading `Code.pul`, the bootstrap redirects that failure to a SHA-256 of timers and memory, the approach upstream wfc-patcher-wii uses. It checks the instruction words first. If Retro Rewind updates and they change, the build warns and the game logs `RR WiiVC: salt fallback not applied`; the offsets at the top of `loader\src\bootstrap.c` and in `scripts\build-wiivc.ps1` then need updating.
- **Save import.** The build packs `input\save\` into `/WiiVC/SaveImport.bin`. The bootstrap reads it before the game loads its save and writes the files with the game's own ISFS functions. A marker file (`WiiVCImport.id`) records the bundle ID and which files are done.
- If the bootstrap cannot load `Code.pul`, it shows `RR WiiVC: cannot load Code.pul (error N)`. The numbers are listed at `LOAD_MISSING` in `loader\src\bootstrap.c`.
- An earlier build placed the bootstrap at `0x80384E00`. That is inside the main thread's stack, which the OS zeroes during boot, and it caused the black screen.

## Credits

- [Retro Rewind](https://rwfc.net) and [Pulsar](https://github.com/Retro-Rewind-Team/Pulsar): the mod, Retro WFC, and the Kamek loader that the bootstrap reimplements.
- [Wiimm](https://wit.wiimm.de): Wiimms ISO Tools and the original ISO-builder scripts in `kit\`.
- [WiiLink wfc-patcher-wii](https://github.com/WiiLink24/wfc-patcher-wii): the timer-and-memory salt approach used for the error 20911 fix.
- [UWUVCI AIO](https://github.com/stuff-by-3-random-dudes/UWUVCI-AIO-WPF): Wii U Virtual Console injection.
- [devkitPro / libogc](https://devkitpro.org): the RR VR Import homebrew.
