#!/usr/bin/env python3
"""Validate the regional Kamek command streams in a Retro Rewind Code.pul."""

from __future__ import annotations

import argparse
import struct
from pathlib import Path


ARG4 = {1, 4, 5, 6, 10, 32, 33, 34, 64, 65}
ARG8 = {35, 36, 37, 38}
REGIONS = ("PAL", "NTSC-U", "NTSC-J", "NTSC-K")


def be16(data: bytes, offset: int) -> int:
    return struct.unpack_from(">H", data, offset)[0]


def be32(data: bytes, offset: int) -> int:
    return struct.unpack_from(">I", data, offset)[0]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("code_pul", type=Path)
    args = parser.parse_args()

    data = args.code_pul.read_bytes()
    sizes = struct.unpack_from(">4I", data, 0)
    section_offset = 16
    print(f"{args.code_pul}: {len(data)} bytes")
    for name, section_size in zip(REGIONS, sizes):
        if section_size == 0:
            print(f"  {name:7} absent")
            continue
        section = data[section_offset : section_offset + section_size]
        if len(section) != section_size:
            raise SystemExit(f"{name}: truncated section")
        if be32(section, 0) != 0x4B616D65 or be16(section, 4) != 0x6B00:
            raise SystemExit(f"{name}: invalid Kamek magic")
        version = be16(section, 6)
        bss_size = be32(section, 8)
        code_size = be32(section, 12)
        ctor_start = be32(section, 16)
        ctor_end = be32(section, 20)
        declared_length = be32(section, 24)
        cursor = 32 + code_size
        counts: dict[int, int] = {}
        absolute_dol = 0
        absolute_rel = 0
        relative = 0
        while cursor < len(section):
            if cursor + 4 > len(section):
                raise SystemExit(f"{name}: truncated command header at {cursor:#x}")
            command_header = be32(section, cursor)
            cursor += 4
            command = command_header >> 24
            address = command_header & 0xFFFFFF
            if address == 0xFFFFFE:
                if cursor + 4 > len(section):
                    raise SystemExit(f"{name}: truncated absolute address")
                address = be32(section, cursor)
                cursor += 4
                if address < 0x8050BF50:
                    absolute_dol += 1
                else:
                    absolute_rel += 1
            else:
                relative += 1
            counts[command] = counts.get(command, 0) + 1
            if command in ARG4:
                cursor += 4
            elif command in ARG8:
                cursor += 8
            else:
                raise SystemExit(f"{name}: unknown command {command} at {cursor - 4:#x}")
            if cursor > len(section):
                raise SystemExit(f"{name}: command overruns section")
        print(
            f"  {name:7} version={version} section=0x{section_size:x} "
            f"code=0x{code_size:x} bss=0x{bss_size:x} ctors={ctor_start:#x}-{ctor_end:#x} "
            f"declared=0x{declared_length:x} commands={sum(counts.values())} "
            f"relative={relative} dol={absolute_dol} rel={absolute_rel}"
        )
        section_offset += section_size
    if section_offset != len(data):
        raise SystemExit(f"trailing data: 0x{len(data) - section_offset:x} bytes")


if __name__ == "__main__":
    main()
