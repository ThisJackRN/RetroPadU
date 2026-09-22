#!/usr/bin/env python3
"""Inspect and compare Wii DOL section layouts."""

from __future__ import annotations

import argparse
import struct
from pathlib import Path


def u32s(data: bytes, offset: int, count: int) -> tuple[int, ...]:
    return struct.unpack_from(f">{count}I", data, offset)


def sections(data: bytes):
    offsets = u32s(data, 0x00, 18)
    addresses = u32s(data, 0x48, 18)
    sizes = u32s(data, 0x90, 18)
    for index, (offset, address, size) in enumerate(zip(offsets, addresses, sizes)):
        if size:
            kind = "text" if index < 7 else "data"
            yield index, kind, offset, address, size


def inspect(path: Path) -> None:
    data = path.read_bytes()
    print(f"{path} ({len(data)} bytes)")
    for index, kind, offset, address, size in sections(data):
        print(
            f"  {index:02d} {kind:4} file=0x{offset:08x} "
            f"mem=0x{address:08x}-0x{address + size:08x} size=0x{size:x}"
        )
    bss_address, bss_size, entry = u32s(data, 0xD8, 3)
    print(f"  bss      mem=0x{bss_address:08x}-0x{bss_address + bss_size:08x} size=0x{bss_size:x}")
    print(f"  entry    0x{entry:08x}")


def compare(left: Path, right: Path) -> None:
    a = left.read_bytes()
    b = right.read_bytes()
    limit = min(len(a), len(b))
    differences = [i for i in range(limit) if a[i] != b[i]]
    if len(a) != len(b):
        differences.extend(range(limit, max(len(a), len(b))))
    print(f"different bytes: {len(differences)}")
    if not differences:
        return
    runs = []
    start = previous = differences[0]
    for offset in differences[1:]:
        if offset != previous + 1:
            runs.append((start, previous + 1))
            start = offset
        previous = offset
    runs.append((start, previous + 1))
    print(f"different runs: {len(runs)}")
    for start, end in runs[:100]:
        print(f"  file=0x{start:08x}-0x{end:08x} size=0x{end-start:x}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+", type=Path)
    args = parser.parse_args()
    for path in args.paths:
        inspect(path)
    if len(args.paths) == 2:
        compare(*args.paths)


if __name__ == "__main__":
    main()
