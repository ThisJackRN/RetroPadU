# RetroPadU

Play **Retro Rewind**, the Mario Kart Wii custom track pack, on the Wii U as a Virtual Console title. You start it from the Wii U Menu like any other game. The GamePad is both the controller and the screen, and online play runs on Retro WFC.

RetroPadU is a builder for Windows. You give it your own Mario Kart Wii disc image and the Retro Rewind pack, and it builds a WBFS image. You then turn that image into a Wii U title with UWUVCI AIO and install it.

> [!WARNING]
> **This project is in beta.** It has been tested on a single Wii U. Bugs are possible, including ones that affect save data.
>
> - Back up your SD card and your Mario Kart Wii / Retro Rewind save before using it.
> - A Retro Rewind update can break online play until RetroPadU is updated (see [Updating](#updating)).
> - Use at your own risk.

## Contents

- **Getting started:** [Features](#features) · [Requirements](#requirements) · [Building](#building) · [Installing on the Wii U](#installing-on-the-wii-u)
- **Playing:** [Controllers](#controllers) · [Online play](#online-play) · [Saves and VR](#saves-and-vr) · [My Stuff](#my-stuff)
- **Help:** [Updating](#updating) · [Troubleshooting](#troubleshooting)
- **Reference:** [Build options](#build-options) · [Project layout](#project-layout) · [How it works](#how-it-works) · [Credits](#credits) · [Disclaimer](#disclaimer)

## Features

- **Runs as a Wii U Virtual Console title.** It starts from the Wii U Menu. You don't need Riivolution, a USB loader, or the Retro Rewind files on your SD card, because everything is built into the image.
- **Online play.** Virtual Console titles normally can't log in to Retro WFC (error 20911). The image includes a fix.
- **Save and VR import.** Your existing save and VR are copied onto the console the first time the game starts, with backups.
- **My Stuff.** Custom fonts, HUD and music from your `MyStuff` folder are built into the image.

## Requirements

### To build

- A Windows 10 or 11 PC.
- Mario Kart Wii **USA** (RMCE01) as `.iso`, `.wbfs`, `.wdf`, `.wia` or `.ciso`.
  - The PAL, Japanese and Korean versions are not supported.
  - Convert `.rvz` and `.nkit` files to `.iso` first. In Dolphin, right-click the game, choose **Convert File...**, then **ISO**.
- The Retro Rewind pack from [rwfc.net/downloads](https://rwfc.net/downloads), extracted. The folder that matters is `RetroRewind6`.

### To play

- A Wii U with homebrew (Aroma or Tiramisu).
- [UWUVCI AIO](https://github.com/stuff-by-3-random-dudes/UWUVCI-AIO-WPF) on your PC, to create and install the inject.

## Building

1. **Download `RetroPadU.exe`** from the [Releases page](https://github.com/ThisJackRN/RetroPadU/releases) and put it in any folder. Nothing else needs to be installed.
2. **Open it** and pick:
   - your Mario Kart Wii disc,
   - the Retro Rewind pack (the `RetroRewind6` folder, or the folder you extracted the pack into),
   - optionally your save and VR. See [Saves and VR](#saves-and-vr) to find out whether you need them.

   You can also drop files onto the window.
3. **Press Build.** It takes a few minutes.

The result goes to a `RetroPadU output` folder next to the exe:

| Path | Contents |
| --- | --- |
| `Mario Kart Retro Rewind WiiVC [RMCETO].wbfs` | The image to inject |
| `sd-card\` | A spare copy of your save files and the RR VR Import homebrew, in case the automatic import fails (see [Fallback: SD card](#fallback-sd-card)) |
| `build-log.txt` | The full build output |

If Windows shows "Windows protected your PC" the first time, click **More info**, then **Run anyway**. The window remembers your files for next time.

### Without the window (`BUILD.cmd`)

`BUILD.cmd` runs the same build from a folder, without the window. You need:

- `RetroPadU-files.zip` from the [Releases page](https://github.com/ThisJackRN/RetroPadU/releases) (or a clone of this repository), extracted.
- [Wiimms ISO Tools](https://wit.wiimm.de) (wit) installed. Restart the PC after installing it.

Then:

1. **Add your game and pack** to the `input` folder:
   ```
   input\
     Mario Kart Wii (USA).iso
     RetroRewind6\
       Binaries\Code.pul
       ...
   ```
   The `RetroRewind6` folder can also sit one level deeper, inside the folder you extracted the pack into.
2. **Optional:** add your save to `input\save\` and your My Stuff files to `input\MyStuff\` (see [Saves and VR](#saves-and-vr) and [My Stuff](#my-stuff)).
3. **Double-click `BUILD.cmd`.** The result goes to `output\`. To change how it builds, see [Build options](#build-options).

Both ways, the build stops with a message saying what is wrong if something is missing or unsupported, for example the wrong game region, a modified disc or a missing pack.

## Installing on the Wii U

In UWUVCI AIO, create a **Wii** inject from the WBFS with these settings:

| Setting | Value |
| --- | --- |
| Use GamePad as | **Classic Controller** |
| Disable GamePad | **Unchecked**, so the GamePad shows the game |
| Title ID | Any. To replace an earlier RetroPadU inject, reuse its title ID. To keep both, pick a new one. |

Your progress is kept either way, because every RetroPadU inject uses the same save (see [Where your save is](#where-your-save-is)).

## Controllers

With **Use GamePad as: Classic Controller**, the GamePad is your controller and also shows the game. Mario Kart Wii sees it as a Classic Controller.

### Local multiplayer with Wii Remotes

Wii Remotes can't connect to an inject that uses the GamePad as a controller, and re-syncing them doesn't help. This comes from how Virtual Console handles the GamePad, not from RetroPadU or your console.

For local multiplayer, make a second inject from the same WBFS:

| Setting | Value |
| --- | --- |
| Use GamePad as | **Do not use. WiiMotes only** |
| Disable GamePad | **Unchecked**, so the GamePad still shows the game |
| Title ID | A **different** one from your GamePad inject, so you keep both |

In that inject every player uses a Wii Remote, on its own or with a Nunchuk or Classic Controller. Both injects share the same save, so licenses, unlocks and VR carry over.

If a Wii Remote still won't connect, sync it with the Wii U first: press the console's SYNC button, then the red button on the remote. If that doesn't work, also sync it in **Wii Menu** (vWii) mode.

## Online play

Online play uses Retro WFC, the same servers as the Riivolution version of Retro Rewind.

Import your VR before your first online race (see [Saves and VR](#saves-and-vr)). Otherwise you race with the default 5000 VR, and that is what gets uploaded.

## Saves and VR

### Where your save is

The inject keeps its save on the console, in the Wii save slot `RMCR`. The Wiimm USB-loader build of Retro Rewind uses the same slot.

> [!CAUTION]
> If the game says the save data is corrupted and offers to delete it, back out unless you are sure you have no Retro Rewind save.

### Do you need to import anything?

| How you have played Retro Rewind so far | What to do |
| --- | --- |
| With a USB loader on this Wii U | Nothing. The inject already uses that save and VR. |
| With Riivolution from an SD card, or on another console | Import your save and VR (below). |
| Never | Nothing. Start fresh. |

Retro Rewind keeps your progress in two files:

| File | What it holds | Where it is on a Riivolution SD card |
| --- | --- | --- |
| `rksys.dat` | Licenses, Miis, unlocks and your Retro WFC profile | `riivolution\save\RetroWFC\RMCE\` (`RetroWFC2` if "Separate Savegame" was on). Keep `banner.bin` next to it. |
| `RRRating.pul` | Your VR and BR, per profile | `RetroRewind6\RRRating.pul` |

### Automatic import (recommended)

Pick the two files in the RetroPadU window (or copy them into `input\save\` for `BUILD.cmd`) and build. The build lists the profiles and VR it found, so you can check them before installing.

The first time the game starts, it:

1. Backs up the files it is about to change, on the console, to `/shared2/Pulsar/RetroRewind6/WiiVC-backup-*`.
2. Writes `rksys.dat` and `banner.bin` as the inject's save. This **replaces** the save already on the console, so only import `rksys.dat` if the console has no save you want to keep.
3. Merges `RRRating.pul` by profile. Your imported profiles replace the same profiles on the console, and any other profiles are kept.
4. Records what it imported. Each file is imported only once, so rebuilding or reinstalling later never resets your VR.

If the console has never had a Mario Kart Wii save, `rksys.dat` can't be written on the very first start. Let the game create a save, then restart it, and the import finishes. The VR is imported on the first start either way.

### Fallback: SD card

If the automatic import doesn't work, use the `sd-card` folder from the build output:

1. Copy its contents to the root of your SD card.
2. **VR:** in vWii mode, start **RR VR Import** from the Homebrew Channel, using a Wii Remote or GameCube controller. Check the profiles on screen and press A. It merges by profile and backs up the old file to `sd:/RRRating-vwii-backup.pul`.
3. **Save:** in vWii mode, open the `RMCR` save in SaveGame Manager GX and extract it. In the extracted folder, replace `rksys.dat` with the copy from `RetroRewind save backup\` on the SD card, then restore the save.

## My Stuff

Riivolution's **My Stuff** option doesn't exist in an inject, so the build puts your My Stuff files into the image instead.

- Put your files in `RetroRewind6\MyStuff\` (or `input\MyStuff\` for `BUILD.cmd`).
- Each file replaces every game file with the same name, as in Riivolution. For example, `Font.szs` replaces `Scene/UI/Font.szs`.
- `title_bg.brstm`, `offline_bg.brstm` and `wifi_bg.brstm` are always added to `sound\strm` as menu music.
- The build log shows what each file replaced, and which files were skipped because no game file has that name.

To change My Stuff, update the folder and build again. To leave it out, turn off **Include My Stuff** in the window (or run `BUILD.cmd -NoMyStuff`).

## Updating

Each time you update, build again and install the new inject with the **same title ID**. Your save and VR stay on the console.

### A new Retro Rewind version

Extract the new pack, pick it in the window (or replace `input\RetroRewind6`), and build.

Most updates only change tracks, characters or music, and need nothing else. If the build warns that `Code.pul` is a different version, the update changed the game code. The game still works offline, but online play may fail with error 20911 until a RetroPadU update supports the new version.

### A new RetroPadU version

Download the new `RetroPadU.exe` and build again. For `BUILD.cmd`, download the new `RetroPadU-files.zip` and move your files from the old `input` folder into the new one.

> [!TIP]
> Once your save and VR are on the console, remove them from the window (or from `input\save\`). A build without save files never imports anything, so it can't touch your progress.

## Troubleshooting

### While building

| Problem | What to do |
| --- | --- |
| `wit` is not installed (`BUILD.cmd`) | Install [Wiimms ISO Tools](https://wit.wiimm.de) and restart the PC, or use `RetroPadU.exe`, which includes it. |
| "not Mario Kart Wii USA" | Only the USA disc (RMCE01) is supported. |
| "main.dol is modified" | Use a clean, unmodified dump of the game. |
| `.rvz` / `.nkit` not supported | Convert the file to `.iso` in Dolphin first. |
| Warning that `Code.pul` is a different version | Your Retro Rewind pack is newer than RetroPadU. See [A new Retro Rewind version](#a-new-retro-rewind-version). |

### On the Wii U

| Problem | What to do |
| --- | --- |
| Black screen on boot | Make sure you injected the WBFS that RetroPadU built, not another Retro Rewind image. |
| "cannot load Code.pul (error N)" | The pack is missing or damaged. Extract the pack again and rebuild. |
| GamePad doesn't respond | In UWUVCI, set **Use GamePad as** to **Classic Controller**. |
| Wii Remotes don't connect | This is expected when the GamePad is a controller. See [Local multiplayer with Wii Remotes](#local-multiplayer-with-wii-remotes). |
| Online error 20911 | Your Retro Rewind version is newer than RetroPadU supports. Check the build log for the `Code.pul` warning. |
| VR shows 5000 | 5000 is Retro Rewind's default. Import your `RRRating.pul` (see [Saves and VR](#saves-and-vr)). |
| Black screen after HOME → Wii Menu | Older RetroPadU builds hang there after online play. Rebuild with the current RetroPadU and reinstall. To get out of the black screen, hold POWER until the console turns off. |
| The game says the save is corrupted | Read [Where your save is](#where-your-save-is) before you let it delete anything. |

## Build options

These options are for `BUILD.cmd`, which passes them to `scripts\build-wiivc.ps1`, for example `BUILD.cmd -NoMyStuff`.

| Option | Effect |
| --- | --- |
| `-Image <path>` | Use a disc image outside `input\` |
| `-Pack <path>` | Use a `RetroRewind6` folder outside `input\` |
| `-Save <path>` | Use a save folder other than `input\save\` |
| `-Rksys <path>`, `-Rating <path>` | Use these save files instead of a save folder (`banner.bin` is taken from beside `rksys.dat`) |
| `-NoSave` | Import no save, even if `input\save\` has files |
| `-Name <text>` | Disc title (default `Mario Kart Retro Rewind WiiVC`) |
| `-NoMyStuff` | Leave My Stuff out of the image |
| `-KeepWork` | Keep the extracted disc in `work\` for inspection |
| `-Output <path>`, `-Work <path>` | Put the result, and the temporary extracted disc, somewhere other than `output\` and `work\` |
| `-WitPath <path>` | Use this `wit.exe` instead of the installed one |
| `-RebuildLoader` | Recompile the loader first. Needs WSL `Ubuntu-24.04` with `powerpc-linux-gnu-gcc` |

## Project layout

| Path | Contents |
| --- | --- |
| `RetroPadU.exe` | The build window. Not in the repository: it is built by `gui\build.cmd` and published on the Releases page. It carries the build script, `kit\`, the loader, `sd-card\` and Wiimms ISO Tools inside it, and runs the same build as `BUILD.cmd`. If you put it in a copy of this repository, it uses that copy's script and `output\` folder instead. |
| `BUILD.cmd` | Builds from the `input` folder without the window |
| `input\` | Your disc image, the pack, and optionally `save\` and `MyStuff\` |
| `output\` | Built images and the `sd-card\` fallback |
| `scripts\build-wiivc.ps1` | The build script |
| `loader\prebuilt\` | The compiled loader that the build adds to the game |
| `loader\src\` | Loader source code |
| `kit\` | The parts of the Retro Rewind ISO-builder kit that the build uses (`copy-files.bat`, `extra\`, a fallback Riivolution XML) |
| `gui\` | Source of `RetroPadU.exe`. `gui\build.cmd` rebuilds it with the C# compiler that ships with Windows. It needs git and Wiimms ISO Tools installed, and packs only files tracked by git. |
| `rrrating-import\` | Source of the RR VR Import homebrew |
| `sd-card\` | The prebuilt RR VR Import homebrew |
| `dev\` | Developer notes (such as the [exit investigation](dev/EXIT-INVESTIGATION.md)) and Python tools for inspecting the game and the Virtual Console firmware (they need `py -m pip install capstone cryptography`). Not needed to build. |

## How it works

<details>
<summary>Technical details</summary>

- **Game files.** The build extracts the disc and runs the ISO kit's `copy-files.bat`. It then applies the pack's own Riivolution XML (`RetroRewind6\xml\RetroRewind6.xml`, the "Pack: Enabled" patch), so the disc gets exactly the files Riivolution would load. The kit is older than current packs and misses some, such as the per-language `Race.szs` and `Common.szs`. The disc's `/patches` folder, which Pulsar reads as loose archive overrides, comes from the pack's `Patches` folder, as with Riivolution. An older kit font placed there made in-race text use the wrong font.
- **Loader.** Riivolution normally installs Retro Rewind's loader over the game code at `0x80004000`, which gives a black screen in Virtual Console. Instead, the build adds a small loader in three free low-memory slots, `0x80002600`, `0x80001C00` and `0x80002520`, and points Retro Rewind's DOL and REL loader hooks at it. The loader applies the `RRLoadPack` memory patches (plus `0x800017D8 = 1` for NAND saves, as in the pack's USB-loader DOL) and loads the unmodified `Binaries/Code.pul`.
- **Online (error 20911).** Retro Rewind creates its Retro WFC login salt with `ES_Sign`, which fails in a Virtual Console inject. After loading `Code.pul`, the loader redirects that failure to a SHA-256 of timers and memory, the approach used by upstream wfc-patcher-wii. It checks the instruction words first. If a Retro Rewind update changes them, the build warns and the game logs `RR WiiVC: salt fallback not applied`; the offsets in `loader\src\bootstrap.c` and `scripts\build-wiivc.ps1` then need updating.
- **HOME → Wii Menu.** Virtual Console returns to the Wii U Menu only when the System Menu launch arrives on the most recently opened `/dev/es` handle. Going online opens `/dev/es` again, so the stock game would hang on a black screen. The loader reopens `/dev/es` just before that launch. If the launch still fails, the game falls back to the SDK's own hot reset, which also returns to the Wii U Menu. Details are in [dev/EXIT-INVESTIGATION.md](dev/EXIT-INVESTIGATION.md).
- **Save import.** The build packs `input\save\` into `/WiiVC/SaveImport.bin`. The loader reads it before the game loads its save and writes the files with the game's own ISFS functions. A marker file (`WiiVCImport.id`) records the bundle ID and which files are done. The game logs the result as `RR WiiVC: save import N`: `0` imported, `1` already done, `-10`/`-11`/`-12` a file that will be retried on the next start.
- **Loader errors.** If the loader cannot load `Code.pul`, it shows `RR WiiVC: cannot load Code.pul (error N)`. The numbers are listed at `LOAD_MISSING` in `loader\src\bootstrap.c`.

</details>

## Credits

- [Retro Rewind](https://rwfc.net) and [Pulsar](https://github.com/Retro-Rewind-Team/Pulsar): the mod, Retro WFC, and the Kamek loader that RetroPadU's loader reimplements.
- [Wiimm](https://wit.wiimm.de): Wiimms ISO Tools and the original ISO-builder scripts in `kit\`. `RetroPadU.exe` includes Wiimms ISO Tools and the Cygwin DLLs it runs on, unmodified; see [gui\THIRD-PARTY-NOTICES.txt](gui/THIRD-PARTY-NOTICES.txt) for their licenses (GPL-2.0, LGPL-3.0 and others) and source code.
- [WiiLink wfc-patcher-wii](https://github.com/WiiLink24/wfc-patcher-wii): the salt approach used for the error 20911 fix.
- [UWUVCI AIO](https://github.com/stuff-by-3-random-dudes/UWUVCI-AIO-WPF): Wii U Virtual Console injection.
- [devkitPro / libogc](https://devkitpro.org): the RR VR Import homebrew.

## Disclaimer

RetroPadU is a fan project. It is not affiliated with or endorsed by Nintendo or the Retro Rewind team.

It contains no Nintendo game files or Retro Rewind pack files; you need your own legally obtained copies. Mario Kart Wii, Wii and Wii U are trademarks of Nintendo.
