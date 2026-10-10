# RetroPadU

Play **Retro Rewind on your Wii U with the GamePad**, using it as both the controller and the screen. Launch the game from the Wii U Menu and play online through Retro WFC.

RetroPadU is a Windows tool that combines your Mario Kart Wii disc image with the Retro Rewind pack. It creates a **WBFS game image**, which you turn into an installable Wii U Virtual Console title using UWUVCI AIO.

**Setup:** Download RetroPadU → build the game image → create the Wii U title → install and play.

> [!WARNING]
> **Beta — tested on one Wii U.** Back up your SD card and Mario Kart Wii / Retro Rewind save before using it. Bugs may affect save data.

## Get started

### 1. Gather what you need

- **Windows 10 or 11.**
- **A clean Mario Kart Wii USA disc image** (game ID `RMCE01`). Supported formats: `.iso`, `.wbfs`, `.wdf`, `.wia` and `.ciso`. Other regions are not supported.
- **The extracted Retro Rewind pack** from [rwfc.net/downloads](https://rwfc.net/downloads). You need the `RetroRewind6` folder containing `Binaries\Code.pul`.
- **[UWUVCI AIO](https://github.com/stuff-by-3-random-dudes/UWUVCI-AIO-WPF)** to create the installable Wii U title.
- **A homebrew-enabled Wii U** running Aroma or Tiramisu, with an SD card and a WUP installer.

If your image is `.rvz`, `.gcz` or `.nkit`, convert or restore it to a clean `.iso` first. For formats Dolphin can convert, right-click the game and choose **Convert File… → ISO**. RetroPadU rejects modified game executables.

### 2. Build the game image

1. Download **`RetroPadU.exe`** from [Releases](https://github.com/ThisJackRN/RetroPadU/releases) and place it in a folder. It includes the tools needed for the build.
2. Open it and select your **Mario Kart Wii disc image** and **Retro Rewind pack folder**. You can also drag them onto the window.
3. To bring over existing progress, select your save and VR files. Read [Saves and VR](#saves-and-vr) first: importing a save replaces the console's existing Retro Rewind save.
4. Click **Build** and wait for **Build complete**.
5. Open the **`RetroPadU output`** folder next to the EXE.

The file you need for the next step is:

```text
Mario Kart Retro Rewind WiiVC [RMCETO].wbfs
```

The output folder also contains `build-log.txt` and an `sd-card` folder with the save-import fallback. Your file selections are remembered for the next build. If you run the EXE inside this repository, it uses the repository's `output` folder instead.

### 3. Create and install the Wii U title

1. Open UWUVCI AIO and choose **Wii**. Follow its [Wii inject guide](https://uwuvci-prime.github.io/UWUVCI-Resources/wii/wii.html) for the initial base setup.
2. Select the **WBFS that RetroPadU just built** as the game to inject.
3. Use these controller settings:

   | Setting | Value |
   | --- | --- |
   | Use GamePad as | **Classic Controller** |
   | Disable GamePad | **Unchecked** |
   | Swap L/R and ZL/ZR | **Optional:** check to use the **ZL/ZR triggers** instead of the default **L/R bumpers** |

4. Choose a title ID. **Reuse the old ID to replace an existing RetroPadU title**, or use a different ID to keep both installed.
5. Create the inject and export it as **WUP Installable**. Use **Copy to SD**, or copy the generated title folder into the SD card's `install` folder.
6. Install the title on your Wii U with your WUP installer, then launch it from the **Wii U Menu**.

For Aroma, UWUVCI's [setup guide](https://uwuvci-prime.github.io/UWUVCI-Resources/) also lists the required Sigpatches module.

The Retro Rewind files are built into the image. You do not need Riivolution, a USB loader or the pack files on your SD card to play.

## Playing

### GamePad controls

The settings above make Mario Kart Wii recognize the GamePad as a **Classic Controller**. The game appears on both the TV and GamePad.

> [!WARNING]
> **Local multiplayer does not work with GamePad controller injects.** Using the GamePad as a controller blocks Wii Remote connections, including Nunchuks and Classic Controllers attached to them. Re-syncing the remotes will not fix this Virtual Console limitation.

### Online play

Online play uses **Retro WFC**, the same service as the Riivolution version of Retro Rewind. RetroPadU includes a fix for Virtual Console login error **20911**.

**Import your existing VR before your first online race.** Otherwise, the game starts at the default 5000 VR and uploads that rating.

New Retro Rewind game-code versions may need an updated RetroPadU online fix. Check the build log for a `Code.pul` compatibility warning; see [Updating](#updating).

## Saves and VR

### Do you need to import your progress?

| Your situation | What to do |
| --- | --- |
| You use a USB-loader build of Retro Rewind with the `RMCR` save on this Wii U | No import needed. RetroPadU uses that save. |
| You play through Riivolution, or your progress is on another console | Import your save and VR using the steps below. |
| You are starting fresh | Leave the Save and VR fields empty. |
| RetroPadU already has your license, but your VR is missing | Import only `RRRating.pul`. Leave the Save field empty. |

The game uses the console's Wii save slot **`RMCR`**, regardless of the Wii U title ID you choose.

> [!CAUTION]
> If the game reports corrupted save data and offers to delete it, back out if you have a Retro Rewind save you want to keep. Back it up before attempting recovery.

### Find your files

On a Riivolution SD card:

| File | Contains | Location |
| --- | --- | --- |
| `rksys.dat` | Licenses, Miis, unlocks and your Retro WFC profile | `riivolution\save\RetroWFC\RMCE\` |
| `banner.bin` | Save banner (optional) | Beside `rksys.dat` |
| `RRRating.pul` | VR and BR for each profile | `RetroRewind6\RRRating.pul` |

If you enabled **Separate Savegame**, look in `RetroWFC2` instead of `RetroWFC`.

### Import automatically

1. Select `rksys.dat` in **Save** and `RRRating.pul` in **VR** before building. Keep `banner.bin` beside `rksys.dat` if you have it.
2. Check the profiles and ratings shown in the build log.
3. Build, inject and install the image, then start the game.

On startup, RetroPadU backs up existing files before importing:

- **Save:** `rksys.dat` and, if supplied, `banner.bin` replace the console's Retro Rewind save files. Leave them out if you want to keep the console's current save.
- **VR:** `RRRating.pul` is merged by profile. Imported ratings replace matching profiles; other profiles are kept.
- **Backups:** stored on the console at `/shared2/Pulsar/RetroRewind6/WiiVC-backup-*` for the standard pack.

If the console has no save yet, let the game create one, then restart it to finish the save import. VR can import on the first start.

Completed imports are recorded, so the same set of import files is not reapplied on later starts. **Changing the included save files can trigger a new import.** Once your progress is imported, clear the Save and VR fields before future builds.

### If automatic import fails

Use the `sd-card` folder from your build output:

1. Copy its contents to the root of your SD card.
2. **Import VR:** enter vWii mode and launch **RR VR Import** from the Homebrew Channel. Use a Wii Remote or GameCube controller, check the listed profiles and press **A**. It merges ratings by profile and backs up the old file to `sd:/RRRating-vwii-backup.pul`.
3. **Import the save:** use **SaveGame Manager GX** in vWii mode to extract the console's `RMCR` save. Replace `rksys.dat` in the extracted folder with your copy from `RetroRewind save backup` on the SD card, then restore the save.

## My Stuff

To include custom fonts, HUD files or music, put them in **`RetroRewind6\MyStuff\`** before building. Leave **Include My Stuff** enabled in RetroPadU.

- Files replace game files with the same name. For example, `Font.szs` replaces `Scene/UI/Font.szs`.
- `title_bg.brstm`, `offline_bg.brstm` and `wifi_bg.brstm` are added as menu music.
- The build log lists replacements and files skipped because no matching game file was found.

To change your custom files, update the folder and rebuild. To leave them out, turn off **Include My Stuff**.

## Updating

1. Download the new RetroPadU EXE or extract the new Retro Rewind pack, depending on what you are updating.
2. Select the pack in RetroPadU. **Clear the Save and VR fields** if your progress is already on the console.
3. Build a new WBFS and create a new inject in UWUVCI.
4. Install it using the **same Wii U title ID** to replace your previous version.

Your save and VR remain on the console.

If the build warns that **`Code.pul` is a different version**, the online fix does not recognize that game code. Offline play may still work, but online play may fail with **20911** until RetroPadU supports it.

## Troubleshooting

### Build problems

| Problem | What to check |
| --- | --- |
| Disc rejected as the wrong region | Use Mario Kart Wii **USA (`RMCE01`)**. |
| `main.dol is modified` | Use a clean, unmodified disc dump. |
| `.rvz`, `.gcz` or `.nkit` rejected | Convert or restore the image to a clean `.iso` first. |
| Retro Rewind pack not found | Extract the download and select the folder containing `RetroRewind6\Binaries\Code.pul`, or `RetroRewind6` itself. |
| `wit` not installed when using `BUILD.cmd` | Install [Wiimms ISO Tools](https://wit.wiimm.de) and restart the PC, or use the EXE, which includes it. |
| `Code.pul` version warning | See [Updating](#updating). |

### Wii U problems

| Problem | What to check |
| --- | --- |
| Black screen at launch | Confirm you injected the WBFS built by RetroPadU. |
| `cannot load Code.pul (error N)` | Extract the pack again and rebuild; the pack may be missing or damaged. |
| GamePad does not respond | Set **Use GamePad as → Classic Controller** in UWUVCI. |
| Wii Remotes will not connect | GamePad controller injects block Wii Remote connections. See [GamePad controls](#gamepad-controls). |
| Online error **20911** | Check for a `Code.pul` compatibility warning in the build log. Rebuild with a RetroPadU version that supports your pack. |
| VR shows **5000** | Import your `RRRating.pul` before racing online. |
| Black screen after **HOME → Wii Menu** | Older builds could hang after online play. Rebuild with the current RetroPadU. To recover from the hang, hold POWER until the console turns off. |
| Corrupted save message | Do not delete a save you want to keep. See [Saves and VR](#saves-and-vr). |

For other build failures, check the end of **`build-log.txt`** in the output folder.

## Building with BUILD.cmd

Use this method if you prefer building without the graphical app.

1. Download and extract **`RetroPadU-files.zip`** from [Releases](https://github.com/ThisJackRN/RetroPadU/releases), or clone this repository.
2. Install [Wiimms ISO Tools](https://wit.wiimm.de), then restart the PC.
3. Place your disc and pack in `input`:

   ```text
   input\
     Mario Kart Wii (USA).iso
     RetroRewind6\
       Binaries\Code.pul
       ...
   ```

4. Optional: put import files in `input\save\` and custom files in `input\MyStuff\`. The pack's own `MyStuff` folder also works.
5. Double-click **`BUILD.cmd`**. The WBFS and `sd-card` fallback are written to **`output\`**.
6. Follow [Create and install the Wii U title](#3-create-and-install-the-wii-u-title).

The builder also finds `RetroRewind6` inside an extracted pack folder under `input`. Keep only one disc image in `input`.

<details>
<summary><strong>Command-line options</strong></summary>

Pass options to `BUILD.cmd`. Quote paths or names that contain spaces:

```bat
BUILD.cmd -NoSave -NoMyStuff
BUILD.cmd -Image "D:\Games\Mario Kart Wii.iso" -Pack "D:\Packs\RetroRewind6"
```

| Option | Purpose |
| --- | --- |
| `-Image <path>` | Select a disc image outside `input` |
| `-Pack <path>` | Select a `RetroRewind6` folder outside `input` |
| `-Save <path>` | Select an import folder instead of `input\save` |
| `-Rksys <path>`, `-Rating <path>` | Select individual import files; `banner.bin` is read from beside `rksys.dat` |
| `-NoSave` | Skip all save and VR imports |
| `-NoMyStuff` | Skip custom files |
| `-Name <text>` | Set the disc title; default: `Mario Kart Retro Rewind WiiVC` |
| `-Output <path>`, `-Work <path>` | Set output and temporary work folders |
| `-KeepWork` | Keep the extracted disc in the work folder |
| `-WitPath <path>` | Select a specific `wit.exe` |
| `-RebuildLoader` | Recompile the loader; requires WSL `Ubuntu-24.04` with `powerpc-linux-gnu-gcc` |

For updates to the ZIP version, extract the new release and move your disc, pack and custom files into its `input` folder. Remove files from `input\save` once they have been imported.

</details>

## Developer reference

<details>
<summary><strong>Project files and implementation</strong></summary>

### Project files

| Path | Purpose |
| --- | --- |
| `gui\` | C# app source. Run `gui\build.cmd` to build `RetroPadU.exe`; requires Git and Wiimms ISO Tools. The payload includes only Git-tracked project files. |
| `BUILD.cmd` | Entry point for builds without the app |
| `scripts\build-wiivc.ps1` | Shared build script |
| `input\`, `output\` | Build inputs and results |
| `loader\src\`, `loader\prebuilt\` | Loader source and compiled binaries |
| `kit\` | ISO-builder scripts, supporting files and fallback Riivolution XML |
| `rrrating-import\`, `sd-card\` | RR VR Import source and prebuilt homebrew |
| `dev\` | Investigation notes and inspection tools; not required for normal builds |

The EXE bundles the build script, kit, loader, SD fallback and Wiimms ISO Tools. When run inside this repository, it uses the local build script and project files.

### How it works

- **Game files:** extracts the disc, runs the kit's `copy-files.bat`, then applies the pack's Riivolution XML (`RetroRewind6\xml\RetroRewind6.xml`, “Pack: Enabled”). The pack's `Patches` folder supplies loose archive overrides; My Stuff replacements are applied afterward.
- **Loader:** uses free memory slots at `0x80002600`, `0x80001C00` and `0x80002520`, avoiding the Virtual Console conflict with Riivolution's loader at `0x80004000`. It applies `RRLoadPack` patches, enables NAND saves with `0x800017D8 = 1` and loads the unmodified `Binaries/Code.pul`.
- **Online fix:** replaces the failed `ES_Sign` login-salt path with a SHA-256 fallback based on timers and memory. Instruction checks prevent applying the patch to unrecognized code. Supporting changed code requires updating `loader\src\bootstrap.c` and `scripts\build-wiivc.ps1`.
- **Exit fix:** reopens `/dev/es` before launching the System Menu, with an SDK hot-reset fallback. See [the exit investigation](dev/EXIT-INVESTIGATION.md).
- **Save import:** embeds `/WiiVC/SaveImport.bin` and writes files through the game's ISFS functions. `WiiVCImport.id` records the bundle ID and completed entries. Log values: `0` imported, `1` already imported, `-10 - n` failed entry `n`, retried on the next start.
- **Loader errors:** codes for `cannot load Code.pul (error N)` are defined at `LOAD_MISSING` in `loader\src\bootstrap.c`.

The Python inspection tools in `dev\tools` use `capstone` and `cryptography` (`py -m pip install capstone cryptography`).

</details>

## Credits

- [Retro Rewind](https://rwfc.net) and [Pulsar](https://github.com/Retro-Rewind-Team/Pulsar): the mod, Retro WFC and the Kamek loader reimplemented here.
- [Wiimm](https://wit.wiimm.de): Wiimms ISO Tools and the original ISO-builder scripts. The EXE bundles unmodified Wiimms ISO Tools and Cygwin DLLs; see [third-party notices](gui/THIRD-PARTY-NOTICES.txt) for licenses and source information.
- [WiiLink wfc-patcher-wii](https://github.com/WiiLink24/wfc-patcher-wii): the login-salt fallback approach.
- [UWUVCI AIO](https://github.com/stuff-by-3-random-dudes/UWUVCI-AIO-WPF): Wii U Virtual Console injection.
- [devkitPro / libogc](https://devkitpro.org): tools used for RR VR Import.

## Disclaimer

RetroPadU is a fan project, unaffiliated with Nintendo or the Retro Rewind team. It includes no Nintendo game files or Retro Rewind pack files; supply your own legally obtained copies. Mario Kart Wii, Wii and Wii U are trademarks of Nintendo.
