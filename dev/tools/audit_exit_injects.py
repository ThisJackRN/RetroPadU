#!/usr/bin/env python3
"""Compare extracted Wii VC launch files and audit NTSC-U Kamek exit patches."""
import argparse
import hashlib
import struct
from pathlib import Path
from dol_inspect import sections
from validate_code_pul import ARG4, ARG8, be32

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('analysis', type=Path)
    args = parser.parse_args()
    stock, modded = (args.analysis / x for x in ('stock', 'modded'))
    for p in sorted((stock / 'code').iterdir()):
        q = modded / 'code' / p.name
        print(f'code/{p.name}: {"IDENTICAL" if p.read_bytes() == q.read_bytes() else "DIFFERENT"}')
    a, b = ((x / 'extracted/main.dol').read_bytes() for x in (stock, modded))
    for i, kind, off, base, size in sections(a):
        other = next(s for s in sections(b) if s[0] == i)
        assert other[3:] == (base, size)
        changed = []
        for at in range(0, size, 4):
            old, new = a[off+at:off+at+4], b[other[2]+at:other[2]+at+4]
            if old != new:
                changed.append((base+at, old.hex(), new.hex()))
        print(f'Original DOL section {i} ({kind}): {len(changed)} changed words')
        for address, old, new in changed:
            print(f'  {address:08x}: {old} -> {new}')
    for i, _, off, base, size in sections(b):
        if i not in {s[0] for s in sections(a)}:
            print(f'Added section {i}: {base:08x}+{size:x}, sha256={hashlib.sha256(b[off:off+size]).hexdigest()}')
    data = (modded / 'extracted/Code.pul').read_bytes()
    sizes = struct.unpack_from('>4I', data)
    section = data[16+sizes[0]:16+sizes[0]+sizes[1]]
    assert section[:8] == b'Kamek\0\0\2'
    cursor = 32 + be32(section, 12)
    absolute = []
    while cursor < len(section):
        word = be32(section, cursor)
        cursor += 4
        command, address = word >> 24, word & 0xffffff
        is_absolute = address == 0xfffffe
        if is_absolute:
            address = be32(section, cursor)
            cursor += 4
        size = 4 if command in ARG4 else 8 if command in ARG8 else None
        assert size is not None and cursor + size <= len(section)
        values = struct.unpack_from('>' + 'I'*(size//4), section, cursor)
        cursor += size
        if is_absolute:
            absolute.append((command, address, values))
    assert cursor == len(section)
    print(f'Code.pul NTSC-U: {len(absolute)} absolute commands')
    for lo, hi, name in ((0x80000000,0x80004000,'low memory'),
                         (0x80167000,0x80167e00,'ESP'),
                         (0x80192f00,0x80195000,'IOS IPC'),
                         (0x801a0000,0x801ae000,'OS'),
                         (0x801dc000,0x801ef000,'network SDK')):
        matches = [x for x in absolute if lo <= x[1] < hi]
        print(f'{name}: {len(matches)} explicit patch targets')
        for cmd, address, values in matches[:12]:
            print(f'  cmd={cmd} address={address:08x} values=' + ','.join(f'{v:08x}' for v in values))
        if len(matches) > 12:
            print(f'  ... {len(matches)-12} more; last target {matches[-1][1]:08x}')
    print('This audits static commands only; constructors and downloaded payloads may patch more code.')

if __name__ == '__main__':
    main()
