#!/usr/bin/env python3
"""Disassemble selected ranges of a Wii VC fw.img (IOS ELF, no modifications).

Ranges are ADDRESS:LENGTH in IOS virtual addresses. Code is Thumb unless the
range is suffixed with :arm, e.g. 0x20100000:0x40:arm.
"""
import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).with_name('vendor')))
from capstone import Cs, CS_ARCH_ARM, CS_MODE_ARM, CS_MODE_BIG_ENDIAN, CS_MODE_THUMB


def segments(image):
    """(vaddr, bytes) for each loaded segment of the ELF after the fw.img loader."""
    header_size, loader_size = struct.unpack_from('>II', image)
    elf = image[header_size + loader_size:]
    assert elf[:4] == b'\x7fELF'
    phoff, = struct.unpack_from('>I', elf, 28)
    phnum, = struct.unpack_from('>H', elf, 44)
    for i in range(phnum):
        kind, offset, vaddr, _, filesz = struct.unpack_from('>5I', elf, phoff + i * 32)
        if kind == 1 and filesz:
            yield vaddr, elf[offset:offset + filesz]


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('fw', type=Path)
parser.add_argument('ranges', nargs='+', help='ADDRESS:LENGTH[:arm], e.g. 0xffff4368:0x30')
args = parser.parse_args()
loaded = list(segments(args.fw.read_bytes()))
for spec in args.ranges:
    parts = spec.split(':')
    address, length = int(parts[0], 0), int(parts[1], 0)
    mode = CS_MODE_ARM if parts[2:] == ['arm'] else CS_MODE_THUMB
    md = Cs(CS_ARCH_ARM, mode | CS_MODE_BIG_ENDIAN)
    md.skipdata = True
    for base, data in loaded:
        if base <= address and address + length <= base + len(data):
            print(f'\n{args.fw}: {address:08x} + {length:x}')
            for ins in md.disasm(data[address - base:address - base + length], address):
                print(f'{ins.address:08x}  {ins.bytes.hex():8}  {ins.mnemonic:8} {ins.op_str}')
            break
    else:
        raise SystemExit(f'Range not present in fw.img: {spec}')
