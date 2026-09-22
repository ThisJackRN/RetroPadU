#!/bin/sh
# Builds boot.dol for the Homebrew Channel. Pass AUTO_CONFIRM=1 for an unattended
# test build (writes without waiting for a button press).
set -eu

cd "$(dirname "$0")"
DKP=${DEVKITPRO:-/c/devkitPro}
[ -d "$DKP" ] || DKP=/c/devkitPro
BIN=$DKP/devkitPPC/bin
OUT=apps/RRRatingImport/boot.dol
mkdir -p build apps/RRRatingImport

defines=""
if [ "${AUTO_CONFIRM:-0}" = 1 ]; then
    defines="-DAUTO_CONFIRM"
    OUT=build/test-autoconfirm.dol
fi

"$BIN/powerpc-eabi-gcc" -O2 -Wall -Wextra -Werror $defines \
    -DGEKKO -mrvl -mcpu=750 -meabi -mhard-float \
    -I"$DKP/libogc/include" \
    source/main.c -o build/rrrating-import.elf \
    -L"$DKP/libogc/lib/wii" -lwiiuse -lbte -lfat -logc -lm

"$DKP/tools/bin/elf2dol" build/rrrating-import.elf "$OUT"
ls -l "$OUT"
