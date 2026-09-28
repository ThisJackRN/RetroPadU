ENTRY(rr_bootstrap)

/* Mario Kart Wii (USA) functions the loader calls, defined here so the calls
   compile to a direct bl. From 0x80150000 up, each is its PAL symbol - 0xA0. */
sprintf = 0x80010ECC;
DVDConvertPathToEntrynum = 0x8015DEAC;
DVDFastOpen = 0x8015E1B4;
DVDClose = 0x8015E4C8;
DVDReadPrio = 0x8015E794;
ISFS_CreateDir = 0x80169DD4;
ISFS_CreateFile = 0x8016ABD4;
ISFS_Open = 0x8016ADBC;
ISFS_Read = 0x8016B15C;
ISFS_Write = 0x8016B220;
ISFS_Close = 0x8016B2E4;
IOS_Open = 0x80193858;
IOS_Close = 0x80193A38;
IOS_Ioctlv = 0x80194540;
IOS_IoctlvReboot = 0x8019461C;
OSCreateAlarm = 0x801A0570;
OSSetPeriodicAlarm = 0x801A0840;
OSReport = 0x801A2530;
OSFatal = 0x801A4E24;
OSGetTime = 0x801AACBC;
NETSHA1Init = 0x801D2454;
NETSHA1Update = 0x801D24A4;
NETSHA1GetDigest = 0x801D2558;

/* Free low memory. Code.pul writes 0x80001800-0x80001BFF and reads Riivolution
   flags at 0x80002370-0x80002513; the OS globals start at 0x80003000.
   All slots are loaded as DOL text sections, so any may hold code. */
MEMORY
{
    low (rwx) : ORIGIN = 0x80001C00, LENGTH = 0x770
    exit (rwx) : ORIGIN = 0x80002520, LENGTH = 0xE0
    main (rwx) : ORIGIN = 0x80002600, LENGTH = 0xA00
}

SECTIONS
{
    /* Listed first so .text.import, .text.low and .text.exit are not claimed by
       the main slot's *(.text*). */
    .low : ALIGN(4) { *(.text.import) *(.text.low) *(.rodata*) *(.data*) } > low
    /* The build script's exit hook branches to the start of this slot. */
    .exit : ALIGN(4) { *(.text.exit) } > exit
    .text : ALIGN(4) { *(.text.rr_bootstrap) *(.text*) } > main
    /DISCARD/ : { *(.comment*) *(.eh_frame*) *(.note*) *(.got*) *(.sdata*) *(.sbss*) }
}
