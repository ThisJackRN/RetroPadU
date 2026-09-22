#!/usr/bin/env python3
"""Disassemble a raw big-endian PowerPC blob and flag self references."""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).with_name("vendor")))
from capstone import CS_ARCH_PPC, CS_MODE_32, CS_MODE_BIG_ENDIAN, Cs


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("blob", type=Path)
    parser.add_argument("--base", type=lambda value: int(value, 0), default=0x80004000)
    parser.add_argument("--compare-dol", type=Path)
    args = parser.parse_args()

    data = args.blob.read_bytes()
    end = args.base + len(data)
    print(f"blob={args.blob} size=0x{len(data):x} range=0x{args.base:08x}-0x{end:08x}")

    if args.compare_dol:
        dol = args.compare_dol.read_bytes()
        at = dol.find(data)
        print(f"exact blob in DOL: {('0x%x' % at) if at >= 0 else 'not found'}")
        same = 0
        for left, right in zip(data, dol[0x100 : 0x100 + len(data)]):
            if left != right:
                break
            same += 1
        print(f"common prefix with first DOL text section: 0x{same:x}")

    print("aligned words that point inside the blob:")
    for offset in range(0, len(data) - 3, 4):
        value = struct.unpack_from(">I", data, offset)[0]
        if args.base <= value < end:
            print(f"  +0x{offset:04x}: 0x{value:08x}")

    md = Cs(CS_ARCH_PPC, CS_MODE_32 | CS_MODE_BIG_ENDIAN)
    print("instructions with an internal address literal or branch target:")
    previous = None
    for insn in md.disasm(data, args.base):
        line = f"  0x{insn.address:08x}: {insn.mnemonic:8} {insn.op_str}"
        show = False
        if insn.mnemonic.startswith("b"):
            for token in insn.op_str.replace(",", " ").split():
                try:
                    value = int(token, 0)
                except ValueError:
                    continue
                if args.base <= value < end:
                    show = True
        if previous and previous.mnemonic in {"lis", "addis"}:
            try:
                hi = int(previous.op_str.split(",")[-1].strip(), 0) & 0xFFFF
            except ValueError:
                hi = -1
            if hi == (args.base >> 16):
                show = True
                print(
                    f"  0x{previous.address:08x}: {previous.mnemonic:8} "
                    f"{previous.op_str}  [possible self reference pair]"
                )
        if show:
            print(line)
        previous = insn


if __name__ == "__main__":
    main()
