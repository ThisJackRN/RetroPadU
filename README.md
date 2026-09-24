# RetroPadU

Play **Retro Rewind** (the Mario Kart Wii custom track pack) on the Wii U as a Virtual Console title. You get the GamePad as both controller and screen, and online play on Retro WFC.

RetroPadU is a one-click Windows builder. You supply your own Mario Kart Wii disc image and the Retro Rewind pack, and it produces a WBFS image ready to inject with UWUVCI AIO.

> [!WARNING]
> **This project is in beta.** It has been tested on a single Wii U. Bugs are possible, including ones that affect save data.
>
> - Back up your SD card and your Mario Kart Wii / Retro Rewind save before using it.
> - Updates to Retro Rewind can break parts of the build (see [Troubleshooting](#troubleshooting)).
> - Use at your own risk.

> [!IMPORTANT]
> RetroPadU is a fan project. It is not affiliated with or endorsed by Nintendo or the Retro Rewind team. It contains no Nintendo game files or Retro Rewind pack files; you need your own legally obtained copies.

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Injecting with UWUVCI](#injecting-with-uwuvci)
- [Bringing your save and VR](#bringing-your-save-and-vr)
- [My Stuff](#my-stuff)
- [Updating Retro Rewind](#updating-retro-rewind)
- [Troubleshooting](#troubleshooting)
- [Build options](#build-options)
- [Project layout](#project-layout)
- [How it works](#how-it-works)
- [Credits](#credits)

## Features

- **GamePad support.** The GamePad works as a Classic Controller and keeps showing the game.
- **Online play.** Connects to Retro WFC. Fixes error 20911, which blocks online play in Virtual Console injects.
- **Same content as Riivolution.** The disc gets the same files the pack's own Riivolution setup loads, including all tracks, characters, music and languages.
- **Save and VR import.** Put your old save and `RRRating.pul` in a folder, and they are copied onto the console the first time the game starts, with backups.
- **My Stuff.** Custom fonts, HUD and music from your `MyStuff` folder are built into the image.
- **One click.** Drop in two things, double-click `BUILD.cmd`. The only thing to install is Wiimms ISO Tools.

## Requirements

**To build:**

- A Windows 10 or 11 PC.
- [Wiimms ISO Tools](https://wit.wiimm.de) (wit). Install it, then restart the PC.
- Mario Kart Wii **USA** (RMCE01) as `.iso`, `.wbfs`, `.wdf`, `.wia` or `.ciso`. The PAL, Japanese and Korean versions are not supported. `.rvz` and `.nkit` files need converting to `.iso` first (in Dolphin: right-click the game, **Convert File...**, **ISO**).
- The Retro Rewind pack from [rwfc.net/downloads](https://rwfc.net/downloads), extracted. You need the `RetroRewind6` folder.

**To play:**

- A Wii U with homebrew (Aroma or Tiramisu) and [UWUVCI AIO](https://github.com/stuff-by-3-random-dudes/UWUVCI-AIO-WPF) on your PC to create and install the inject.

## Quick start

1. **Get the files.** Download or clone this repository.
2. **Add your game and pack.** Put these in the `input` folder:
   ```
   input\
     Mario Kart Wii (USA).iso
     RetroRewind6\
       Binaries\Code.pul
       ...
   ```
   The `RetroRewind6` folder can also be inside the folder you extracted the pack into.
3. **Optional: add your save and My Stuff.** See [Bringing your save and VR](#bringing-your-save-and-vr) and [My Stuff](#my-stuff).
4. **Build.** Double-click `BUILD.cmd`. A full build takes a few minutes.
5. **Collect the result.** When it finishes:
   - `output\Mario Kart Retro Rewind WiiVC [RMCETO].wbfs` is the image to inject.
   - `output\sd-card\` is a fallback copy of your save files plus a homebrew tool (see [Bringing your save and VR](#bringing-your-save-and-vr)).

The build stops with a clear message if something is missing or wrong, for example the wrong game region, a modified disc, or a missing pack.

## Injecting with UWUVCI

Create a **Wii** inject from the WBFS with these settings:

| Setting | Value |
| --- | --- |
| Use GamePad as | **Classic Controller** |
| Disable GamePad | **Unchecked**, so the picture stays on the GamePad |
| Title ID | Your own. Use the same one as an earlier RetroPadU inject to replace it, or a new one to keep both |

> [!CAUTION]
> If the game says the save data is corrupted and offers to delete it, back out unless you are sure you have no Retro Rewind save. The inject uses the Wii save slot `RMCR`, the same one as the Wiimm USB-loader build of Retro Rewind.

## Bringing your save and VR

Retro Rewind keeps your progress in two files:

| File | What it holds | Where it usually is |
| --- | --- | --- |
| `rksys.dat` (with `banner.bin`) | Licenses, Miis, unlocks and your Retro WFC profile | SD card: `riivolution\save\RetroWFC\RMCE\` (`RetroWFC2` if "Separate Savegame" was on) |
| `RRRating.pul` | Your VR and BR, per profile | SD card: `RetroRewind6\RRRating.pul` |

### Automatic import (recommended)

Copy the files you want into `input\save\` and build. The build lists the profiles and VR it found, so you can check them before installing.

The first time the game starts, it:

1. Backs up the files it is about to change, on the console, to `/shared2/Pulsar/RetroRewind6/WiiVC-backup-*`.
2. Writes `rksys.dat` and `banner.bin` as the inject's save. This **replaces** the existing save, so leave `rksys.dat` out if the inject already shows your license.
3. Merges `RRRating.pul` by profile: your profiles overwrite the same profiles on the console, and any others are kept.
4. Records what it imported. Each file is imported once, so rebuilding or reinstalling later never resets your VR.

If the console has never had a save for this game, the save files can't be written on the very first start. Let the game create a save, then restart it, and the import finishes. The VR is imported on the first start either way.

> [!NOTE]
> Don't race online before your VR has been imported. Races upload the VR the game currently has.

### Fallback: SD card

If the automatic import doesn't work, use `output\sd-card\`:

1. Copy the contents of `output\sd-card\` to the root of your SD card.
2. For VR: start **RR VR Import** from the Homebrew Channel in vWii mode, using a Wii Remote or GameCube controller. Check the profiles on screen and press A. It merges by profile and backs up the old copy to `sd:/RRRating-vwii-backup.pul`.
3. For the save: use SaveGame Manager GX in vWii mode on the `RMCR` save. Extract it, replace `rksys.dat` in the extracted folder with the copy from `RetroRewind save backup\`, and restore it.

## My Stuff

Riivolution's **My Stuff** option doesn't exist in an inject, so the build puts your My Stuff files into the image instead.

- Put your files in `RetroRewind6\MyStuff\` or `input\MyStuff\`.
- Each file replaces every file with the same name in the game, the same way Riivolution does. For example, `Font.szs` replaces `Scene/UI/Font.szs`.
- `title_bg.brstm`, `offline_bg.brstm` and `wifi_bg.brstm` are always added as menu music.
- The build prints what each file replaced and skips files whose name isn't in the game.

To change My Stuff, update the folder and build again. To build without it, run `BUILD.cmd -NoMyStuff`.

## Updating Retro Rewind

When a new Retro Rewind version comes out:

1. Replace `input\RetroRewind6` with the new pack.
2. Build again and reinstall the inject.

Your save and VR stay on the console. The save import does not run again unless you change the files in `input\save\`.

If the build warns that `Code.pul` is a different version, the game should still work offline, but online play may fail with error 20911 until RetroPadU is updated.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| `wit` is not installed | Install [Wiimms ISO Tools](https://wit.wiimm.de) and restart the PC. |
| "not Mario Kart Wii USA" | Only the USA disc (RMCE01) is supported. |
| "main.dol is modified" | Use a clean, unmodified dump of the game. |
| `.rvz` / `.nkit` not supported | Convert the file to `.iso` in Dolphin first. |
| Black screen on boot | Make sure you injected the WBFS from `output\`, not another Retro Rewind image. |
| GamePad doesn't respond | In UWUVCI, set **Use GamePad as** to **Classic Controller**. |
| Online error 20911 | Your Retro Rewind version is newer than RetroPadU supports. Watch the build output for the `Code.pul` warning. |
| VR shows 5000 | 5000 is Retro Rewind's default. Add your `RRRating.pul` to `input\save\` and rebuild, or use the [SD card fallback](#fallback-sd-card). |
| "cannot load Code.pul (error N)" | The pack is missing or damaged. Re-extract the pack and build again. |

## Build options

`BUILD.cmd` passes options to `scripts\build-wiivc.ps1`, for example `BUILD.cmd -NoMyStuff`.

| Option | Effect |
| --- | --- |
| `-Image <path>` | Use a disc image outside `input\` |
| `-Pack <path>` | Use a `RetroRewind6` folder outside `input\` |
| `-Save <path>` | Use a save folder other than `input\save\` |
| `-Name <text>` | Disc title (default `Mario Kart Retro Rewind WiiVC`) |
| `-NoMyStuff` | Leave My Stuff out of the image |
| `-KeepWork` | Keep the extracted disc in `work\` for inspection |
| `-RebuildLoader` | Recompile the loader first. Needs WSL `Ubuntu-24.04` with `powerpc-linux-gnu-gcc` |

## Project layout

| Path | Contents |
| --- | --- |
| `BUILD.cmd` | One-click build |
| `input\` | Your disc image, the pack, and optionally `save\` and `MyStuff\` |
| `output\` | Built images and the `sd-card\` fallback |
| `scripts\build-wiivc.ps1` | The build script |
| `loader\prebuilt\` | The compiled loader that the build adds to the game |
| `loader\src\` | Loader source code |
| `kit\` | The parts of the Retro Rewind ISO-builder kit that the build uses (`copy-files.bat`, `extra\`, a fallback Riivolution XML) |
| `rrrating-import\` | Source of the RR VR Import homebrew |
| `sd-card\` | The prebuilt RR VR Import homebrew |
| `dev\` | Developer tools for inspecting game code, and the old build scripts. Not needed to build |

## How it works

<details>
<summary>Technical details</summary>

- **Game files.** The build extracts the disc and runs the ISO kit's `copy-files.bat`. It then applies the pack's own Riivolution XML (`RetroRewind6\xml\RetroRewind6.xml`, the "Pack: Enabled" patch), so the disc gets exactly the files Riivolution would load. The kit is older than current packs and misses some, such as the per-language `Race.szs` and `Common.szs`. The disc's `/patches` folder, which Pulsar reads as loose archive overrides, comes from the pack's `Patches` folder, as with Riivolution. An older kit font placed there made in-race text use the wrong font.
- **Loader.** Riivolution normally installs Retro Rewind's loader over the game code at `0x80004000`, which gives a black screen in Virtual Console. Instead, the build adds a small loader in three free low-memory slots, `0x80002600`, `0x80001C00` and `0x80002520`, and points Retro Rewind's DOL and REL loader hooks at it. The loader applies the `RRLoadPack` memory patches (plus `0x800017D8 = 1` for NAND saves, as in the pack's USB-loader DOL) and loads the unmodified `Binaries/Code.pul`.
- **Online (error 20911).** Retro Rewind creates its Retro WFC login salt with `ES_Sign`, which fails in a fake-signed Virtual Console inject. After loading `Code.pul`, the loader redirects that failure to a SHA-256 of timers and memory, the approach used by upstream wfc-patcher-wii. It checks the instruction words first. If a Retro Rewind update changes them, the build warns and the game logs `RR WiiVC: salt fallback not applied`; the offsets in `loader\src\bootstrap.c` and `scripts\build-wiivc.ps1` then need updating.
- **Save import.** The build packs `input\save\` into `/WiiVC/SaveImport.bin`. The loader reads it before the game loads its save and writes the files with the game's own ISFS functions. A marker file (`WiiVCImport.id`) records the bundle ID and which files are done. The game logs the result as `RR WiiVC: save import N`: `0` imported, `1` already done, `-10`/`-11`/`-12` a file that will be retried on the next start.
- **Loader errors.** If the loader cannot load `Code.pul`, it shows `RR WiiVC: cannot load Code.pul (error N)`. The numbers are listed at `LOAD_MISSING` in `loader\src\bootstrap.c`.

</details>

## Credits

- [Retro Rewind](https://rwfc.net) and [Pulsar](https://github.com/Retro-Rewind-Team/Pulsar): the mod, Retro WFC, and the Kamek loader that RetroPadU's loader reimplements.
- [Wiimm](https://wit.wiimm.de): Wiimms ISO Tools and the original ISO-builder scripts in `kit\`.
- [WiiLink wfc-patcher-wii](https://github.com/WiiLink24/wfc-patcher-wii): the salt approach used for the error 20911 fix.
- [UWUVCI AIO](https://github.com/stuff-by-3-random-dudes/UWUVCI-AIO-WPF): Wii U Virtual Console injection.
- [devkitPro / libogc](https://devkitpro.org): the RR VR Import homebrew.

## Disclaimer

Mario Kart Wii, Wii and Wii U are trademarks of Nintendo. RetroPadU does not include or distribute any Nintendo software or Retro Rewind pack files.
