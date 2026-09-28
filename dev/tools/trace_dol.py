#!/usr/bin/env python3
"""Disassemble selected memory ranges from a DOL (no modifications)."""
import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).with_name('vendor')))
from capstone import Cs, CS_ARCH_PPC, CS_MODE_32, CS_MODE_BIG_ENDIAN
from dol_inspect import sections

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('dol', type=Path)
parser.add_argument('ranges', nargs='+', help='ADDRESS:LENGTH, e.g. 0x801a86b8:0xc0')
args = parser.parse_args()
data = args.dol.read_bytes()
md = Cs(CS_ARCH_PPC, CS_MODE_32 | CS_MODE_BIG_ENDIAN)
md.skipdata = True
for spec in args.ranges:
    address, length = (int(x, 0) for x in spec.split(':'))
    for _, _, offset, base, size in sections(data):
        if base <= address and address + length <= base + size:
            at = offset + address - base
            print(f'\n{args.dol}: {address:08x} + {length:x}')
            for ins in md.disasm(data[at:at+length], address):
                print(f'{ins.address:08x}  {ins.bytes.hex()}  {ins.mnemonic:9} {ins.op_str}')
            break
    else:
        raise SystemExit(f'Range not present in DOL: {spec}')
