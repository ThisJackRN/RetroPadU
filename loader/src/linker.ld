ENTRY(rr_bootstrap)

/* Free low memory. Code.pul writes 0x80001800-0x80001BFF and reads Riivolution
   flags at 0x80002370-0x80002513; the OS globals start at 0x80003000.
   Both slots are loaded as DOL text sections, so either may hold code. */
MEMORY
{
    low (rwx) : ORIGIN = 0x80001C00, LENGTH = 0x770
    main (rwx) : ORIGIN = 0x80002600, LENGTH = 0xA00
}

SECTIONS
{
    /* Listed first so .text.import is not claimed by the main slot's *(.text*). */
    .low : ALIGN(4) { *(.text.import) *(.rodata*) *(.data*) } > low
    .text : ALIGN(4) { *(.text.rr_bootstrap) *(.text*) } > main
    /DISCARD/ : { *(.comment*) *(.eh_frame*) *(.note*) *(.got*) *(.sdata*) *(.sbss*) }
}
