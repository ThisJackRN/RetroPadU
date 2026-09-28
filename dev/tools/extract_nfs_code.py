#!/usr/bin/env python3
"""Extract DOL/FST/Code.pul from a decrypted Wii VC title, leaving NFS intact.

EGGS extent layout and AES sector IVs follow FIX94/nfs2iso2nfs Program.cs.
Only the needed sectors are decrypted; no complete ISO is generated.
"""
import argparse
import functools
import hashlib
import struct
from pathlib import Path
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

def u32(data, at=0):
    return struct.unpack_from('>I', data, at)[0]

class NFS:
    def __init__(self, title):
        self.files = [p.open('rb') for p in sorted((title / 'content').glob('hif_*.nfs'))]
        self.sizes = [p.seek(0, 2) for p in self.files]
        self.key = (title / 'code/htk.bin').read_bytes()
        header = self.raw(0, 0x200)
        assert header[:4] == b'EGGS' and header[-4:] == b'SGGE'
        assert 0 < u32(header, 0x10) <= 61
        self.extents = []
        physical = 0
        for i in range(u32(header, 0x10)):
            start, count = struct.unpack_from('>II', header, 0x14 + i*8)
            self.extents.append((start, count, physical))
            physical += count

    def raw(self, offset, length):
        chunks = []
        for f, size in zip(self.files, self.sizes):
            if offset >= size:
                offset -= size
                continue
            f.seek(offset)
            chunk = f.read(min(length, size-offset))
            chunks.append(chunk)
            length -= len(chunk)
            offset = 0
            if not length:
                return b''.join(chunks)
        raise ValueError('NFS read beyond end')

    @functools.lru_cache(maxsize=128)
    def sector(self, index):
        for start, count, physical in self.extents:
            if start <= index < start + count:
                slot = physical + index - start
                iv = (index if slot >= 3 else 0).to_bytes(16, 'big')
                decrypt = Cipher(algorithms.AES(self.key), modes.CBC(iv)).decryptor()
                return decrypt.update(self.raw(0x200 + slot*0x8000, 0x8000)) + decrypt.finalize()
        return bytes(0x8000)

    def read(self, offset, length):
        chunks = []
        while length:
            index, within = divmod(offset, 0x8000)
            n = min(length, 0x8000-within)
            chunks.append(self.sector(index)[within:within+n])
            offset += n
            length -= n
        return b''.join(chunks)

    def partition_read(self, offset, length):
        chunks = []
        while length:
            index, within = divmod(offset, 0x7c00)
            n = min(length, 0x7c00-within)
            chunks.append(self.read(self.data_start + index*0x8000 + 0x400 + within, n))
            offset += n
            length -= n
        return b''.join(chunks)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('title', type=Path)
    args = parser.parse_args()
    nfs = NFS(args.title)
    header = nfs.read(0, 0x100)
    assert u32(header, 0x18) == 0x5d1c9ea3, 'Bad decrypted disc magic'
    table = nfs.read(0x40000, 0x20)
    partitions = []
    for i in range(4):
        count, offset = struct.unpack_from('>II', table, i*8)
        assert count < 100
        for j in range(count):
            start, kind = struct.unpack('>II', nfs.read(offset*4+j*8, 8))
            if kind == 0:
                partitions.append(start*4)
    assert len(partitions) == 1
    partition = partitions[0]
    nfs.data_start = partition + u32(nfs.read(partition+0x2b8, 4))*4
    boot = nfs.partition_read(0, 0x440)
    assert u32(boot, 0x18) == 0x5d1c9ea3, 'Bad decrypted partition magic'
    out = args.title / 'extracted'
    out.mkdir(exist_ok=True)
    def save(name, data):
        target = out / name
        if target.exists() and target.read_bytes() != data:
            raise ValueError(f'Refusing to overwrite different file: {target}')
        target.write_bytes(data)
        print(f'{name}: {len(data)} bytes SHA256 {hashlib.sha256(data).hexdigest()}')
    print(f'{args.title}: disc={header[:6]!r}, partition={partition:#x}, data={nfs.data_start:#x}')
    save('boot.bin', boot)
    dol_at, fst_at, fst_len = (u32(boot, x)*4 for x in (0x420, 0x424, 0x428))
    dol = nfs.partition_read(dol_at, 0x100)
    size = max(u32(dol, i*4) + u32(dol, 0x90+i*4) for i in range(18))
    assert 0x100 < size < 0x1800000
    save('main.dol', nfs.partition_read(dol_at, size))
    fst = nfs.partition_read(fst_at, fst_len)
    save('fst.bin', fst)
    count = u32(fst, 8)
    assert count*12 <= len(fst)
    for i in range(1, count):
        flags, offset, size = struct.unpack_from('>III', fst, i*12)
        if flags >> 24:
            continue
        name_at = count*12 + (flags & 0xffffff)
        name = fst[name_at:fst.index(b'\0', name_at)].decode('utf-8')
        if name in ('Code.pul', 'StaticR.rel'):
            save(name, nfs.partition_read(offset*4, size))

if __name__ == '__main__':
    main()
