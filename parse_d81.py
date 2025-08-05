import sys
from collections import defaultdict

SECTOR_SIZE = 256
TRACKS = 80
SECTORS_PER_TRACK = 40
DISK_SIZE = TRACKS * SECTORS_PER_TRACK * SECTOR_SIZE

def get_sector_offset(track, sector):
    return ((track - 1) * SECTORS_PER_TRACK + sector) * SECTOR_SIZE

def read_sector(image, track, sector):
    return image[get_sector_offset(track, sector):get_sector_offset(track, sector) + SECTOR_SIZE]

def parse_disk_header(sector):
    next_dir_t = sector[0]
    next_dir_s = sector[1]
    dos_version = chr(sector[2])
    disk_label = sector[0x04:0x14].rstrip(b'\xA0').decode('ascii', errors='ignore')
    disk_id = sector[0x16:0x18].decode('ascii', errors='ignore')
    dos_type = chr(sector[0x19])
    disk_version = chr(sector[0x1A])

    print("=== DISK HEADER ===")
    print(f"Next Dir T/S : {next_dir_t}/{next_dir_s}")
    print(f"DOS Version  : {dos_version} {sector[2]}")
    print(f"Disk Label   : {disk_label}")
    print(f"Disk ID      : {disk_id}")
    print(f"DOS Type     : {dos_type}")
    print(f"Disk Version : {disk_version}")

def parse_bam(image):
    print("\n=== BAM INFO ===")

    # BAM for tracks 1–40
    bam1 = read_sector(image, 40, 1)
    bam_bitmap1 = bam1[0x04:0x04 + 5 * 40]  # 5 bytes × 40 tracks
    for i in range(40):
        entry = bam_bitmap1[i * 5 : (i + 1) * 5]
        free_sectors = entry[0]
        print(f"Track {i + 1:02}: Free sectors: {free_sectors}")

    # BAM for tracks 41–80
    bam2 = read_sector(image, 40, 2)
    bam_bitmap2 = bam2[0x04:0x04 + 5 * 40]
    for i in range(40):
        entry = bam_bitmap2[i * 5 : (i + 1) * 5]
        free_sectors = entry[0]
        print(f"Track {i + 41:02}: Free sectors: {free_sectors}")

def hex_dump(data: bytes):
    return ' '.join(f"{b:02X}" for b in data) + "  |" + ''.join((chr(b) if 32 <= b < 127 else '.') for b in data) + "|"


def parse_directory(image, start_track=40, start_sector=3):
    used_ts = defaultdict(list)  # maps (track, sector) to a list of filenames

    print("\n=== DIRECTORY ENTRIES ===")
    visited = set()
    track, sector = start_track, start_sector
    while track != 0:
        print(f"Scanning T:{track} S:{sector}...")
        if (track, sector) in visited:
            print(f"Loop detected at T:{track} S:{sector}, aborting.")
            break
        visited.add((track, sector))

        data = read_sector(image, track, sector)
        next_track, next_sector = data[0], data[1]

        for i in range(8):
            entry = data[2 + i * 32 : 2 + (i + 1) * 32]

            print(f"\nDirectory entry at offset {i:02X}:")
            print(hex_dump(entry))


            status = entry[0]
            ft = status
            ft_track, ft_sector = entry[1], entry[2]
            fn = entry[3:19].replace(b'\xA0', b' ').decode('ascii', 'replace').strip()

            if status & 0x07 == 0:
                print('DELETED FILE')
                fn += ' (DELETED)'
                # NOTE: comment out the 'continue' below if you want to view file-chain of deleted files
                continue

            blocks = entry[28] + (entry[29] << 8)

            print(f"File: {fn:<16} Type: {ft:02X} Start: {ft_track}/{ft_sector} Size: {blocks} blocks")
            chain = follow_chain(image, ft_track, ft_sector)

            parts = []
            for entry in chain:
                if len(entry) == 2 and isinstance(entry[0], int):
                    t, s = entry
                    parts.append(f"{t}/{s}")
                else:
                    parts.append(str(entry[0]))  # e.g. "LOOP!"
            print("   Chain:\n ->", "\n -> ".join(parts))

            for t, s in chain:
                if isinstance(t, int):  # Skip error strings like "Loop detected"
                    used_ts[(t, s)].append(fn)
            
        track, sector = next_track, next_sector

    print(f"End marker T:{track}, S:{sector}")

    # After parsing all entries
    print("\n=== OVERLAPPING T/S ENTRIES ===")
    overlaps = {ts: files for ts, files in used_ts.items() if len(files) > 1}
    if overlaps:
        for (track, sector), files in sorted(overlaps.items()):
            if track != 0:
                print(f"Track/Sector {track}/{sector} used by: {', '.join(files)}")
    else:
        print("No overlaps detected.")

def follow_chain(image, track, sector):
    chain = []
    visited = set()
    while track != 0:
        if (track, sector) in visited:
            chain.append(("LOOP!",))
            break
        visited.add((track, sector))
        chain.append((track, sector))
        data = read_sector(image, track, sector)
        track, sector = data[0], data[1]

    chain.append((track, sector))
    return chain

def main(fn):
    with open(fn, 'rb') as f:
        img = f.read()

    if len(img) != DISK_SIZE:
        print(f"Invalid .d81 size: {len(img)} bytes (expected {DISK_SIZE})")
        return

    print("Reading Track 40 Sectors 0–2 …")
    hdr = read_sector(img, 40, 0)
    parse_disk_header(hdr)

    parse_bam(img)

    parse_directory(img)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python parse_d81.py disk.d81")
    else:
        main(sys.argv[1])
