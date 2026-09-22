/*
 * RRRating import: copies Retro Rewind VR/BR entries from an SD card
 * RRRating.pul into the NAND copy the WiiVC build reads
 * (/shared2/Pulsar/RetroRewind6/RRRating.pul).
 *
 * SD entries replace NAND entries with the same profile ID; every other NAND
 * entry is kept. The existing NAND file is backed up to the SD card first.
 */
#include <gccore.h>
#include <fat.h>
#include <wiiuse/wpad.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

#define MAGIC 0x52525254u /* "RRRT" */
#define VERSION 1
#define MAX_PROFILES 100
#define FILE_SIZE (8 + MAX_PROFILES * 16 + 32) /* matches Pulsar's Save() */

#define NAND_DIR1 "/shared2/Pulsar"
#define NAND_DIR2 "/shared2/Pulsar/RetroRewind6"
#define NAND_FILE "/shared2/Pulsar/RetroRewind6/RRRating.pul"
#define SD_BACKUP "sd:/RRRating-vwii-backup.pul"

static const char *const kSdSources[] = {
    "sd:/RRRating.pul",
    "sd:/RetroRewind6/RRRating.pul",
};

typedef struct {
    s32 profileId;
    f32 vr;
    f32 br;
    u32 flags;
} Entry;

typedef struct {
    u32 magic;
    u16 version;
    u16 count;
    Entry entries[MAX_PROFILES];
    u8 pad[32];
} RatingFile;

static void *xfb;

static void init_video(void) {
    VIDEO_Init();
    GXRModeObj *mode = VIDEO_GetPreferredMode(NULL);
    xfb = MEM_K0_TO_K1(SYS_AllocateFramebuffer(mode));
    console_init(xfb, 20, 20, mode->fbWidth, mode->xfbHeight, mode->fbWidth * VI_DISPLAY_PIX_SZ);
    VIDEO_Configure(mode);
    VIDEO_SetNextFramebuffer(xfb);
    VIDEO_SetBlack(false);
    VIDEO_Flush();
    VIDEO_WaitVSync();
    if (mode->viTVMode & VI_NON_INTERLACE) VIDEO_WaitVSync();
}

/* Returns 1 for A, 0 for HOME/START/B. */
static int wait_confirm(void) {
    for (;;) {
        WPAD_ScanPads();
        PAD_ScanPads();
        u32 wii = WPAD_ButtonsDown(0);
        u16 gc = PAD_ButtonsDown(0);
#ifdef AUTO_CONFIRM
        wii |= WPAD_BUTTON_A;
#endif
        if ((wii & (WPAD_BUTTON_A | WPAD_CLASSIC_BUTTON_A)) || (gc & PAD_BUTTON_A)) return 1;
        if ((wii & (WPAD_BUTTON_HOME | WPAD_BUTTON_B | WPAD_CLASSIC_BUTTON_HOME |
                    WPAD_CLASSIC_BUTTON_B)) ||
            (gc & (PAD_BUTTON_START | PAD_BUTTON_B)))
            return 0;
        VIDEO_WaitVSync();
    }
}

static void finish(int code) {
    printf("\n Press A or HOME to return to the Homebrew Channel.\n");
#ifndef AUTO_CONFIRM
    wait_confirm();
#endif
    exit(code);
}

static int valid(const RatingFile *file, long size) {
    return size >= 8 && file->magic == MAGIC && file->version == VERSION;
}

static int entry_count(const RatingFile *file, long size) {
    int count = file->count < MAX_PROFILES ? file->count : MAX_PROFILES;
    int fits = (int)((size - 8) / (long)sizeof(Entry));
    return count < fits ? count : fits;
}

static void print_entries(const RatingFile *file, int count) {
    int shown = 0;
    for (int i = 0; i < count; ++i) {
        const Entry *e = &file->entries[i];
        if (!(e->flags & 1) || e->profileId <= 0) continue;
        printf("   profile %-10ld VR %5d  BR %5d\n", (long)e->profileId,
               (int)(e->vr * 100.0f + 0.5f), (int)(e->br * 100.0f + 0.5f));
        ++shown;
    }
    if (!shown) printf("   (no profiles)\n");
}

static long read_sd(const char *path, RatingFile *out) {
    FILE *f = fopen(path, "rb");
    if (!f) return -1;
    long size = (long)fread(out, 1, sizeof(*out), f);
    fclose(f);
    return size;
}

static s32 read_nand(RatingFile *out) {
    s32 fd = ISFS_Open(NAND_FILE, ISFS_OPEN_READ);
    if (fd < 0) return fd;
    s32 size = ISFS_Read(fd, out, sizeof(*out));
    ISFS_Close(fd);
    return size;
}

static s32 write_nand(const RatingFile *file) {
    s32 ret = ISFS_CreateDir(NAND_DIR1, 0, ISFS_OPEN_RW, ISFS_OPEN_RW, ISFS_OPEN_RW);
    if (ret < 0 && ret != -105) return ret; /* -105: already exists */
    ret = ISFS_CreateDir(NAND_DIR2, 0, ISFS_OPEN_RW, ISFS_OPEN_RW, ISFS_OPEN_RW);
    if (ret < 0 && ret != -105) return ret;

    s32 fd = ISFS_Open(NAND_FILE, ISFS_OPEN_WRITE);
    if (fd < 0) {
        /* Missing, or owned by the game without write access for us: recreate it. */
        ISFS_Delete(NAND_FILE);
        ret = ISFS_CreateFile(NAND_FILE, 0, ISFS_OPEN_RW, ISFS_OPEN_RW, ISFS_OPEN_RW);
        if (ret < 0) return ret;
        fd = ISFS_Open(NAND_FILE, ISFS_OPEN_WRITE);
        if (fd < 0) return fd;
    }
    ret = ISFS_Write(fd, file, FILE_SIZE);
    ISFS_Close(fd);
    return ret == FILE_SIZE ? 0 : (ret < 0 ? ret : -1);
}

int main(void) {
    init_video();
    WPAD_Init();
    PAD_Init();

    printf("\n Retro Rewind VR import (WiiVC build)\n");
    printf(" ------------------------------------\n\n");

    if (!fatInitDefault()) {
        printf(" Could not open the SD card.\n");
        finish(1);
    }
    if (ISFS_Initialize() < 0) {
        printf(" Could not open the Wii system memory (ISFS).\n");
        finish(1);
    }

    static RatingFile sd ATTRIBUTE_ALIGN(32);
    static RatingFile nand ATTRIBUTE_ALIGN(32);
    static RatingFile out ATTRIBUTE_ALIGN(32);

    const char *source = NULL;
    long sd_size = -1;
    for (unsigned i = 0; i < sizeof(kSdSources) / sizeof(kSdSources[0]); ++i) {
        memset(&sd, 0, sizeof(sd));
        sd_size = read_sd(kSdSources[i], &sd);
        if (sd_size >= 0) {
            source = kSdSources[i];
            break;
        }
    }
    if (!source) {
        printf(" No RRRating.pul found. Put it at sd:/RRRating.pul\n");
        finish(1);
    }
    if (!valid(&sd, sd_size)) {
        printf(" %s is not a Retro Rewind rating file.\n", source);
        finish(1);
    }
    int sd_count = entry_count(&sd, sd_size);
    printf(" SD file (%s):\n", source);
    print_entries(&sd, sd_count);

    memset(&nand, 0, sizeof(nand));
    s32 nand_size = read_nand(&nand);
    int nand_ok = nand_size >= 0 && valid(&nand, nand_size);
    int nand_count = nand_ok ? entry_count(&nand, nand_size) : 0;
    printf("\n Current Wii copy (%s):\n", NAND_FILE);
    if (nand_size < 0)
        printf("   (none yet)\n");
    else if (!nand_ok)
        printf("   (unreadable, will be replaced)\n");
    else
        print_entries(&nand, nand_count);

    /* Merge: start from the NAND entries, then apply each SD entry. */
    memset(&out, 0, sizeof(out));
    out.magic = MAGIC;
    out.version = VERSION;
    out.count = MAX_PROFILES;
    for (int i = 0; i < nand_count; ++i)
        if ((nand.entries[i].flags & 1) && nand.entries[i].profileId > 0) out.entries[i] = nand.entries[i];

    for (int i = 0; i < sd_count; ++i) {
        const Entry *e = &sd.entries[i];
        if (!(e->flags & 1) || e->profileId <= 0) continue;
        int slot = -1, empty = -1;
        for (int j = 0; j < MAX_PROFILES; ++j) {
            if ((out.entries[j].flags & 1) && out.entries[j].profileId == e->profileId) {
                slot = j;
                break;
            }
            if (empty < 0 && !(out.entries[j].flags & 1)) empty = j;
        }
        if (slot < 0) slot = empty;
        if (slot < 0) {
            printf(" No free slot for profile %ld.\n", (long)e->profileId);
            finish(1);
        }
        out.entries[slot] = *e;
    }

    printf("\n After import:\n");
    print_entries(&out, MAX_PROFILES);

    printf("\n Press A to write, or HOME/B to cancel without changes.\n");
    if (!wait_confirm()) {
        printf(" Cancelled. Nothing was changed.\n");
        finish(0);
    }

    if (nand_size > 0) {
        FILE *b = fopen(SD_BACKUP, "wb");
        if (!b || fwrite(&nand, 1, (size_t)nand_size, b) != (size_t)nand_size) {
            if (b) fclose(b);
            printf(" Could not back up the Wii copy to %s. Nothing was changed.\n", SD_BACKUP);
            finish(1);
        }
        fclose(b);
        printf(" Backed up the old Wii copy to %s\n", SD_BACKUP);
    }

    s32 ret = write_nand(&out);
    if (ret < 0) {
        printf(" Writing %s failed (error %ld).\n", NAND_FILE, (long)ret);
        finish(1);
    }

    RatingFile *check = &nand;
    memset(check, 0, sizeof(*check));
    if (read_nand(check) != FILE_SIZE || memcmp(check, &out, FILE_SIZE) != 0) {
        printf(" Wrote the file, but reading it back did not match.\n");
        finish(1);
    }
    printf("\n Done. Your VR is imported; start Retro Rewind.\n");
    ISFS_Deinitialize();
    finish(0);
    return 0;
}
