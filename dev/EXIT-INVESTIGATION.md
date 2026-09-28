# Wii VC exit investigation

## Status

Fixed. The root cause was found by reading the Wii VC firmware
(`code/fw.img`). The fix is `launch_title` in `loader/src/bootstrap.c`. On
2026-09-28 it was confirmed on a Wii U: after online play, HOME → Wii Menu
returns to the Wii U Menu.

Symptom: HOME → Wii Menu returns to the Wii U Menu if the game has not been
online. After online play it hangs on a black screen.

## How a Wii VC game returns to the Wii U Menu

`fw.img` is an unencrypted IOS image (`$IOSVersion: IOS 0.9-svn-r590`). It has
a 16-byte header, an ELF loader, and then an ELF at `0x494`. It is
byte-identical in the stock Mario Kart Wii inject and in the Retro Rewind
inject.

- ES handles `ES_LaunchTitle(1-2)` like a normal PPC title launch
  (`20104db0`) and ends in syscall `0x41` (ppc_boot). In this kernel, syscall
  `0x41` is a stub (`ffff0688`) that logs `LaunchElf: request discarded` and
  returns -1. So ES alone cannot leave the game.
- Instead, the kernel's PPC IPC loop (`ffff3ee4`) intercepts the launch. On
  each PPC open of `/dev/es` it records the fd it returns (`ffff4344`, stored
  at `ffffb818`). It does the same for `/dev/stm/immediate` (`ffff435a`,
  stored at `ffffb81c`). For ioctlv 8 on the recorded ES fd with title 1-2
  (`ffff41e4`, `ffff4368`), it sends STM ioctl `0x2001` (hot reset) on the
  recorded STM fd instead. Wii VC's STM hot reset (`203003b0`) replies 0 and
  resets the console, which lands in the Wii U Menu.
- A close never clears the recorded fd. A failed open still overwrites it,
  with the stale result field of the PPC's request.

## Why online play breaks it

The SDK's ESP library opens `/dev/es` at boot (fd 10) and uses that fd for the
launch. Going online opens `/dev/es` from the PPC again:

- Pulsar's `GenerateRandomSalt` (`rr-pulsar` `57aaea3`,
  `PulsarEngine/Network/WiiLink.cpp`): open, `ES_Sign`, close.
- The Retro WFC payload's `SendExtendedLogin` (`wfc-patcher-wii` `9ee5c2d`,
  `payload/wwfcLogin.cpp`): open, and on `-1016` it borrows ESP's fd.

After either, the recorded fd is no longer 10. The launch then reaches ES,
which returns -1.

## Why the failure is a black screen

`IOS_IoctlvReboot` (`8019461C`) copies its request to `803412A0` and sleeps
on that copy's thread queue. `IpcReplyHandler` (`80192FD4`) wakes the queue of
the original request (`801931E0`), so a failure reply never wakes the caller.
`__LaunchMenu` never returns. As a result, `__OSReturnToMenu` never reaches
its own fallback, `__OSHotReset` (`801AB938`, the same STM ioctl `0x2001`).

This also explains the earlier results:

- The committed hook at `801A8758` only showed an error if `__LaunchMenu`
  returned, and on failure it never does.
- `SOCleanup` before `__LaunchMenu` had nothing to do with the cause. It
  regressed offline exits and was withdrawn.
- Exit Probe 4 reached `80167240` both offline and after online play, with
  identical arguments (`fd 10, ioctl 8, 2 in, 0 out, vectors 80394c30`), IPC
  credits 1, and no reboot pending. The difference is only visible in the
  kernel's recorded fd.

## Fix

At boot, the loader replaces `bl IOS_IoctlvReboot` at `80167240` in
`ESP_LaunchTitle` with `bl launch_title` (exit slot, `80002520`). For title
1-2 only, `launch_title`:

1. Closes the ESP fd and reopens `/dev/es`, so the kernel records the fd that
   the launch uses. This is the stock offline path.
2. Sends the launch with a plain `IOS_Ioctlv` (`80194540`). If ES still
   fails, the call returns. `__LaunchMenu` then returns, and
   `__OSReturnToMenu` runs `__OSHotReset`, which sends the same STM request.

Other launches keep `IOS_IoctlvReboot`. `OSRestart` (HOME → Reset) reaches
`ESP_LaunchTitle` through `__OSRelaunchTitle` with the game's own title.

## Hardware test

To retest after loader changes, inject the release WBFS with the usual UWUVCI
settings, then:

1. Start the game and go straight to HOME → Wii Menu. Expect the Wii U Menu.
2. Start it again, play one online race, then HOME → Wii Menu. Expect the
   Wii U Menu. Before the fix, this case hung.
3. Optionally, try HOME → Reset. It is unchanged by the fix.

## Reproduce

```
py dev/tools/extract_nfs_code.py dev/research/exit-analysis/stock
py dev/tools/trace_fw.py dev/research/exit-analysis/stock/code/fw.img 0xffff4328:0x40 0xffff41e4:0x14 0xffff4368:0x30 0xffff0688:0x10 0x203003b0:0x28
py dev/tools/trace_dol.py dev/research/exit-analysis/stock/extracted/main.dol 0x8019461c:0x2fc 0x80192fd4:0x258 0x801a86b8:0xd0 0x801ab938:0x70
py dev/tools/audit_exit_injects.py dev/research/exit-analysis
```

`extract_nfs_code.py` decrypts the needed NFS sectors with each title's own
`code/htk.bin`. `audit_exit_injects.py` compares the stock and Retro Rewind
packages: the firmware and launcher files are byte-identical, and the DOL
differs only in the two loader hooks (`8000A3B4`, `802417DC`) and the added
loader sections. Extracted Nintendo files stay in ignored folders.
