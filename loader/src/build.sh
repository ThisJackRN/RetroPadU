#!/bin/sh
set -eu

cd "$(dirname "$0")"
mkdir -p build

powerpc-linux-gnu-gcc \
    -Os -ffunction-sections -ffreestanding -fno-builtin -fno-pic -fno-pie -fno-stack-protector \
    -m32 -mbig-endian -mcpu=750 -mhard-float -mno-sdata \
    -Wall -Wextra -Werror -c bootstrap.c -o build/bootstrap.o

powerpc-linux-gnu-ld -EB -T linker.ld -nostdlib \
    --build-id=none -o build/bootstrap.elf build/bootstrap.o \
    "$(powerpc-linux-gnu-gcc -m32 -print-libgcc-file-name)"

# The linker script's MEMORY regions fail the link if any part outgrows its slot.
powerpc-linux-gnu-objcopy -O binary -j .text build/bootstrap.elf build/bootstrap-main.bin
powerpc-linux-gnu-objcopy -O binary -j .low build/bootstrap.elf build/bootstrap-low.bin
powerpc-linux-gnu-objcopy -O binary -j .exit build/bootstrap.elf build/bootstrap-exit.bin
powerpc-linux-gnu-objdump -EB -d build/bootstrap.elf > build/bootstrap.disasm.txt
powerpc-linux-gnu-nm -n build/bootstrap.elf > build/bootstrap.map.txt

wc -c build/bootstrap-main.bin build/bootstrap-low.bin build/bootstrap-exit.bin

# The Windows build script consumes these prebuilt copies.
cp build/bootstrap-main.bin build/bootstrap-low.bin build/bootstrap-exit.bin ../prebuilt/
