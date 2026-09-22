#include <stdint.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef int32_t s32;

typedef void (*OSReportFn)(const char *, ...);
typedef void (*OSFatalFn)(u32 *, u32 *, const char *, ...);
typedef s32 (*DVDConvertPathFn)(const char *);
typedef s32 (*DVDFastOpenFn)(s32, void *);
typedef s32 (*DVDReadPrioFn)(void *, void *, s32, s32, s32);
typedef s32 (*DVDCloseFn)(void *);
typedef s32 (*SprintfFn)(char *, const char *, ...);
typedef void (*SHA1InitFn)(void *);
typedef void (*SHA1UpdateFn)(void *, const void *, u32);
typedef void (*SHA1DigestFn)(void *, void *);

typedef struct {
    u8 command_block[0x30];
    u32 start_address;
    u32 length;
    void *callback;
} DVDFileInfo;

typedef struct {
    u32 magic1;
    u16 magic2;
    u16 version;
    u32 bss_size;
    u32 code_size;
    u32 ctor_start;
    u32 ctor_end;
    u32 length;
    u32 padding;
} KamekHeader;

typedef struct {
    OSReportFn report;
    OSFatalFn fatal;
    DVDConvertPathFn path_to_entry;
    DVDFastOpenFn fast_open;
    DVDReadPrioFn read_prio;
    DVDCloseFn close;
    SprintfFn sprintf;
    void *rk_system;
    SHA1InitFn sha1_init;
    SHA1UpdateFn sha1_update;
    SHA1DigestFn sha1_digest;
    u32 region;
    u32 rel_start;
} LoaderParams;

enum {
    CMD_ADDR32 = 1,
    CMD_ADDR16_LO = 4,
    CMD_ADDR16_HI = 5,
    CMD_ADDR16_HA = 6,
    CMD_REL24 = 10,
    CMD_WRITE32 = 32,
    CMD_WRITE16 = 33,
    CMD_WRITE8 = 34,
    CMD_COND_PTR = 35,
    CMD_COND32 = 36,
    CMD_COND16 = 37,
    CMD_COND8 = 38,
    CMD_BRANCH = 64,
    CMD_BRANCH_LINK = 65,
};

static LoaderParams g_params = {
    (OSReportFn)0x801A2530,
    (OSFatalFn)0x801A4E24,
    (DVDConvertPathFn)0x8015DEAC,
    (DVDFastOpenFn)0x8015E1B4,
    (DVDReadPrioFn)0x8015E794,
    (DVDCloseFn)0x8015E4C8,
    (SprintfFn)0x80010ECC,
    (void *)0x8029FD00,
    (SHA1InitFn)0x801D2454,
    (SHA1UpdateFn)0x801D24A4,
    (SHA1DigestFn)0x801D2558,
    1,
    0x8050BF50,
};

/* Keep persistent state in the loaded DOL section, not in the game's BSS. */
static void *g_code_buffer __attribute__((section(".data"))) = (void *)0;
static u32 g_section_length __attribute__((section(".data"))) = 0;
static u32 g_text __attribute__((section(".data"))) = 0;

static u32 round_up_32(u32 value) { return (value + 31u) & ~31u; }

static void copy_bytes(void *destination, const void *source, u32 length) {
    u8 *out = (u8 *)destination;
    const u8 *in = (const u8 *)source;
    while (length--) *out++ = *in++;
}

static void zero_bytes(void *destination, u32 length) {
    u8 *out = (u8 *)destination;
    while (length--) *out++ = 0;
}

static void cache_code_address(u32 address) {
    __asm__ volatile("dcbst 0,%0\n\tsync\n\ticbi 0,%0" : : "r"(address) : "memory");
}

static void sync_code(void) {
    __asm__ volatile("sync\n\tisync" : : : "memory");
}

static void *heap_alloc(void *heap, u32 size, s32 alignment) {
    void **vtable = *(void ***)heap;
    void *(*allocate)(void *, u32, s32) = (void *(*)(void *, u32, s32))vtable[5];
    return allocate(heap, size, alignment);
}

static void heap_free(void *heap, void *block) {
    void **vtable = *(void ***)heap;
    void (*release)(void *, void *) = (void (*)(void *, void *))vtable[6];
    release(heap, block);
}

static void *system_heap(void) {
    return *(void **)((u8 *)g_params.rk_system + 0x24);
}

static void *mem2_heap(void) {
    return *(void **)((u8 *)g_params.rk_system + 0x1C);
}

/* Code.pul load failures, shown on screen as "error N". */
enum {
    LOAD_MISSING = 1,
    LOAD_OPEN,
    LOAD_HEADER_READ,
    LOAD_FILE_MEMORY,
    LOAD_BODY_READ,
    LOAD_CORRUPT,
    LOAD_VERSION,
    LOAD_CODE_MEMORY,
    LOAD_UNKNOWN_COMMAND,
};

static void fatal(int error) {
    u32 foreground = 0xFFFFFFFF;
    u32 background = 0;
    g_params.fatal(&foreground, &background, "RR WiiVC: cannot load Code.pul (error %d)", error);
}

static u32 resolve_address(u32 text, u32 address) {
    return (address & 0x80000000u) ? address : text + address;
}

static u32 command_payload_size(u8 command) {
    switch (command) {
        case CMD_COND_PTR:
        case CMD_COND32:
        case CMD_COND16:
        case CMD_COND8:
            return 8;
        case CMD_ADDR32:
        case CMD_ADDR16_LO:
        case CMD_ADDR16_HI:
        case CMD_ADDR16_HA:
        case CMD_REL24:
        case CMD_WRITE32:
        case CMD_WRITE16:
        case CMD_WRITE8:
        case CMD_BRANCH:
        case CMD_BRANCH_LINK:
            return 4;
        default:
            fatal(LOAD_UNKNOWN_COMMAND);
            return 0;
    }
}

static const u8 *apply_command(u8 command, const u8 *input, u32 text, u32 address) {
    u32 target;
    u32 value;
    u32 original;
    u32 delta;

    switch (command) {
        case CMD_ADDR32:
            target = resolve_address(text, *(const u32 *)input);
            *(u32 *)address = target;
            return input + 4;
        case CMD_ADDR16_LO:
            target = resolve_address(text, *(const u32 *)input);
            *(u16 *)address = (u16)target;
            return input + 4;
        case CMD_ADDR16_HI:
            target = resolve_address(text, *(const u32 *)input);
            *(u16 *)address = (u16)(target >> 16);
            return input + 4;
        case CMD_ADDR16_HA:
            target = resolve_address(text, *(const u32 *)input);
            *(u16 *)address = (u16)((target + 0x8000u) >> 16);
            return input + 4;
        case CMD_REL24:
            target = resolve_address(text, *(const u32 *)input);
            delta = target - address;
            *(u32 *)address = (*(u32 *)address & 0xFC000003u) | (delta & 0x03FFFFFCu);
            return input + 4;
        case CMD_WRITE32:
            *(u32 *)address = *(const u32 *)input;
            return input + 4;
        case CMD_WRITE16:
            *(u16 *)address = (u16)*(const u32 *)input;
            return input + 4;
        case CMD_WRITE8:
            *(u8 *)address = (u8)*(const u32 *)input;
            return input + 4;
        case CMD_COND_PTR:
            target = resolve_address(text, *(const u32 *)input);
            original = *(const u32 *)(input + 4);
            if (*(u32 *)address == original) *(u32 *)address = target;
            return input + 8;
        case CMD_COND32:
            value = *(const u32 *)input;
            original = *(const u32 *)(input + 4);
            if (*(u32 *)address == original) *(u32 *)address = value;
            return input + 8;
        case CMD_COND16:
            value = *(const u32 *)input;
            original = *(const u32 *)(input + 4);
            if (*(u16 *)address == (u16)original) *(u16 *)address = (u16)value;
            return input + 8;
        case CMD_COND8:
            value = *(const u32 *)input;
            original = *(const u32 *)(input + 4);
            if (*(u8 *)address == (u8)original) *(u8 *)address = (u8)value;
            return input + 8;
        case CMD_BRANCH:
        case CMD_BRANCH_LINK:
            *(u32 *)address = command == CMD_BRANCH ? 0x48000000u : 0x48000001u;
            target = resolve_address(text, *(const u32 *)input);
            delta = target - address;
            *(u32 *)address = (*(u32 *)address & 0xFC000003u) | (delta & 0x03FFFFFCu);
            return input + 4;
        default: /* command_payload_size already rejected unknown commands */
            return input;
    }
}

static void patch_salt_fallback(void);

static void load_kamek(const void *binary, u32 binary_length, int is_dol) {
    const KamekHeader *header = (const KamekHeader *)binary;
    if (header->magic1 != 0x4B616D65u || header->magic2 != 0x6B00u)
        fatal(LOAD_CORRUPT);
    if (header->version != 2) fatal(LOAD_VERSION);

    u32 text_size = header->code_size + header->bss_size;
    if (is_dol) g_text = (u32)heap_alloc(system_heap(), text_size, 0x20);
    if (!g_text) fatal(LOAD_CODE_MEMORY);

    const u8 *input = (const u8 *)binary + sizeof(KamekHeader);
    const u8 *input_end = (const u8 *)binary + binary_length;
    if (is_dol) {
        copy_bytes((void *)g_text, input, header->code_size);
        zero_bytes((void *)(g_text + header->code_size), header->bss_size);
        for (u32 at = g_text; at < g_text + text_size; at += 0x20) cache_code_address(at);
    }
    input += header->code_size;

    u8 sha_context[0x60] __attribute__((aligned(32)));
    u8 *digest = (u8 *)0x800017B0;
    g_params.sha1_init(sha_context);
    g_params.sha1_update(sha_context, (const u8 *)binary + sizeof(KamekHeader), header->code_size);
    g_params.sha1_digest(sha_context, digest);

    while (input < input_end) {
        u32 command_header = *(const u32 *)input;
        input += 4;
        u8 command = (u8)(command_header >> 24);
        u32 payload_size = command_payload_size(command);
        u32 address = command_header & 0x00FFFFFFu;
        if (address == 0x00FFFFFEu) {
            address = *(const u32 *)input;
            input += 4;
            if ((address < g_params.rel_start && !is_dol) ||
                (address >= g_params.rel_start && is_dol)) {
                input += payload_size;
                continue;
            }
        } else {
            if (!is_dol) {
                input += payload_size;
                continue;
            }
            address += g_text;
        }
        const u8 *next = apply_command(command, input, g_text, address);
        input = next;
        cache_code_address(address);
    }
    sync_code();

    if (is_dol) {
        typedef void (*Constructor)(void);
        Constructor *begin = (Constructor *)(g_text + header->ctor_start);
        Constructor *end = (Constructor *)(g_text + header->ctor_end);
        while (begin < end) (*begin++)();
        patch_salt_fallback();
    }
}

/* Pulsar's GenerateRandomSalt derives the Retro WFC payload salt from ES_Sign,
   which fails in a fake-signed WiiVC inject and surfaces as error 20911. When
   it fails, hash timers and memory instead, as upstream wfc-patcher-wii does.
   Offsets are into the current Code.pul text and are checked before patching. */
enum {
    PUL_SALT_CALL = 0x33F88,     /* bl GenerateRandomSalt(r1 + 8) */
    PUL_SALT_FAILED = 0x33F94,   /* lis r3, ...; li r0, -20911; stw r0, ... */
    PUL_SHA256_INIT = 0x331C8,
    PUL_SHA256_UPDATE = 0x333D0,
    PUL_SHA256_FINAL = 0x3349C,
};

typedef void (*Sha256InitFn)(void *);
typedef void (*Sha256UpdateFn)(void *, const void *, u32);
typedef u8 *(*Sha256FinalFn)(void *);

static void fallback_salt(u8 *out) {
    /* Called from the patched site, so the return address locates Code.pul's
       text without relying on bootstrap globals surviving until online play. */
    u32 text = (u32)__builtin_return_address(0) - (PUL_SALT_FAILED + 8);
    u8 context[0xC8] __attribute__((aligned(32)));
    u32 seed[4];
    __asm__ volatile("mftbl %0\n\tmftbu %1\n\tmfdec %2"
                     : "=r"(seed[0]), "=r"(seed[1]), "=r"(seed[2]));
    seed[3] = (u32)out;

    Sha256UpdateFn update = (Sha256UpdateFn)(text + PUL_SHA256_UPDATE);
    ((Sha256InitFn)(text + PUL_SHA256_INIT))(context);
    update(context, seed, sizeof(seed));
    update(context, (const void *)0x80000000, 0x4000);
    update(context, (const void *)0x90000000, 0x1000);
    update(context, (const void *)0x80003130, 0x30000);
    copy_bytes(out, ((Sha256FinalFn)(text + PUL_SHA256_FINAL))(context), 32);
}

static void patch_salt_fallback(void) {
    const u32 *code = (const u32 *)g_text;
    if (code[PUL_SALT_CALL / 4] != 0x4BFFFD01u || code[PUL_SALT_CALL / 4 + 2] != 0x40820014u ||
        code[PUL_SALT_FAILED / 4 + 1] != 0x3800AE51u ||
        code[PUL_SHA256_UPDATE / 4] != 0x9421FFE0u || code[PUL_SHA256_FINAL / 4] != 0x9421FFE0u) {
        g_params.report("RR WiiVC: salt fallback not applied (unknown Code.pul)\n");
        return;
    }

    u32 at = g_text + PUL_SALT_FAILED;
    *(u32 *)at = 0x38610008u;                                    /* addi r3, r1, 8 */
    *(u32 *)(at + 4) = 0x48000001u | (((u32)fallback_salt - (at + 4)) & 0x03FFFFFCu);
    *(u32 *)(at + 8) = 0x48000008u;                              /* b to the success path */
    for (u32 i = 0; i < 12; i += 4) cache_code_address(at + i);
    sync_code();
    g_params.report("RR WiiVC: salt fallback patched at %08x\n", at);
}

/* One-time save import. The build script can pack the player's old save into
   /WiiVC/SaveImport.bin; on boot this copies it to NAND before the game reads
   its save. Existing files are backed up first, VR entries are merged by
   profile ID, and a marker records which files were imported so each one is
   imported only once.
   Errors are only reported: the game always keeps booting. Most of the
   importer lives in the low memory slot (see linker.ld); import_write sits in
   the main slot so both slots fit. */
#define IMPORT_TEXT __attribute__((section(".text.import"), noinline))

enum { IMPORT_REPLACE = 0, IMPORT_MERGE_RATING = 1, IMPORT_CHUNK = 0x8000 };
enum { RATING_HEADER = 8, RATING_ENTRY = 16, RATING_SLOTS = 100, RATING_SIZE = 8 + 100 * 16 + 32 };

typedef struct {
    char path[64];
    char backup[64];
    u32 offset;
    u32 size;
    u32 kind;
    u8 pad[20];
} ImportEntry;

typedef struct {
    u32 magic; /* 'RRVC' */
    u32 version;
    u32 id;
    u32 count;
    u8 pad[16];
    char marker[64];
    char dirs[2][64];
    ImportEntry entries[4];
} ImportBundle;

typedef s32 (*IsfsCreateFn)(const char *, u8, u8, u8, u8);
typedef s32 (*IsfsOpenFn)(const char *, u32);
typedef s32 (*IsfsReadFn)(s32, void *, u32);
typedef s32 (*IsfsWriteFn)(s32, const void *, u32);
typedef s32 (*IsfsCloseFn)(s32);

/* NTSC-U addresses (PAL symbol - 0xA0); Code.pul calls the same ones. */
#define ISFS_CREATE_DIR ((IsfsCreateFn)0x80169DD4)
#define ISFS_CREATE_FILE ((IsfsCreateFn)0x8016ABD4)
#define ISFS_OPEN ((IsfsOpenFn)0x8016ADBC)
#define ISFS_READ ((IsfsReadFn)0x8016B15C)
#define ISFS_WRITE ((IsfsWriteFn)0x8016B220)
#define ISFS_CLOSE ((IsfsCloseFn)0x8016B2E4)

IMPORT_TEXT static s32 import_open_write(const char *path) {
    s32 fd = ISFS_OPEN(path, 2);
    if (fd >= 0) return fd;
    s32 ret = ISFS_CREATE_FILE(path, 0, 3, 3, 3);
    return ret < 0 ? ret : ISFS_OPEN(path, 2);
}

/* Returns bytes read (0 when missing), or a negative error. */
IMPORT_TEXT static s32 import_read(const char *path, void *buf, u32 size) {
    s32 fd = ISFS_OPEN(path, 1);
    if (fd < 0) return 0;
    s32 got = ISFS_READ(fd, buf, size);
    ISFS_CLOSE(fd);
    return got;
}

__attribute__((noinline)) static s32 import_write(const char *path, const void *data, u32 size) {
    s32 fd = import_open_write(path);
    if (fd < 0) return fd;
    s32 put = ISFS_WRITE(fd, data, size);
    ISFS_CLOSE(fd);
    return put == (s32)size ? 0 : -1;
}

IMPORT_TEXT static s32 import_backup(const char *src, const char *dst, u8 *chunk) {
    s32 in = ISFS_OPEN(src, 1);
    if (in < 0) return 0; /* nothing to back up */
    s32 out = import_open_write(dst);
    s32 ret = out;
    if (out >= 0) {
        s32 got;
        while ((got = ISFS_READ(in, chunk, IMPORT_CHUNK)) > 0) {
            if (ISFS_WRITE(out, chunk, (u32)got) != got) {
                got = -1;
                break;
            }
        }
        ret = got;
        ISFS_CLOSE(out);
    }
    ISFS_CLOSE(in);
    return ret < 0 ? ret : 0;
}

/* Merges RRRating.pul entries from src into the NAND copy by profile ID. */
IMPORT_TEXT static s32 import_rating(const ImportEntry *e, const u8 *src, u8 *out) {
    s32 got = import_read(e->path, out, RATING_SIZE);
    if (got < RATING_HEADER || *(const u32 *)out != 0x52525254u) {
        zero_bytes(out, RATING_SIZE);
        *(u32 *)out = 0x52525254u; /* "RRRT", version 1, 100 slots */
        *(u32 *)(out + 4) = 0x00010064u;
    }
    u32 count = *(const u16 *)(src + 6);
    if (count > RATING_SLOTS) count = RATING_SLOTS;
    for (u32 i = 0; i < count && RATING_HEADER + (i + 1) * RATING_ENTRY <= e->size; ++i) {
        const u32 *in = (const u32 *)(src + RATING_HEADER + i * RATING_ENTRY);
        if (!(in[3] & 1) || (s32)in[0] <= 0) continue;
        u32 *slot = 0;
        for (u32 j = 0; j < RATING_SLOTS; ++j) {
            u32 *cand = (u32 *)(out + RATING_HEADER + j * RATING_ENTRY);
            if ((cand[3] & 1) && cand[0] == in[0]) { slot = cand; break; }
            if (!slot && !(cand[3] & 1)) slot = cand;
        }
        if (slot) copy_bytes(slot, in, RATING_ENTRY);
    }
    return import_write(e->path, out, RATING_SIZE);
}

IMPORT_TEXT static void import_save_bundle(void) {
    s32 entry = g_params.path_to_entry("/WiiVC/SaveImport.bin");
    if (entry < 0) return;
    DVDFileInfo file;
    if (!g_params.fast_open(entry, &file)) return;

    void *heap = mem2_heap();
    if (!heap) heap = system_heap();
    u32 length = round_up_32(file.length);
    u8 *buf = (u8 *)heap_alloc(heap, length + IMPORT_CHUNK, -0x20);
    s32 status = -1;
    if (buf && g_params.read_prio(&file, buf, length, 0, 2) >= 0) {
        const ImportBundle *b = (const ImportBundle *)buf;
        u8 *chunk = buf + length;
        status = -2;
        if (b->magic == 0x52525643u && b->version == 1 && b->count <= 4) {
            ISFS_CREATE_DIR(b->dirs[0], 0, 3, 3, 3); /* -105 (exists) is fine */
            ISFS_CREATE_DIR(b->dirs[1], 0, 3, 3, 3);
            /* The marker holds {bundle ID, bitmask of imported entries}. Each file
               is imported exactly once: a failed save write neither blocks the
               VR import nor lets a retry reset VR earned since. Failed entries
               are retried on the next boot. */
            u32 done = 0;
            if (import_read(b->marker, chunk, 32) == 8 && *(const u32 *)chunk == b->id)
                done = *(const u32 *)(chunk + 4);
            u32 all = (1u << b->count) - 1;
            status = (done & all) == all ? 1 : 0; /* 1: already imported */
            for (u32 i = 0; i < b->count; ++i) {
                if (done & (1u << i)) continue;
                const ImportEntry *e = &b->entries[i];
                s32 ret = import_backup(e->path, e->backup, chunk);
                if (ret == 0)
                    ret = e->kind == IMPORT_MERGE_RATING ? import_rating(e, buf + e->offset, chunk)
                                                          : import_write(e->path, buf + e->offset, e->size);
                if (ret < 0) {
                    if (status == 0) status = -10 - (s32)i;
                } else {
                    done |= 1u << i;
                }
            }
            if (status != 1) {
                ((u32 *)chunk)[0] = b->id;
                ((u32 *)chunk)[1] = done;
                if (import_write(b->marker, chunk, 8) < 0 && status == 0) status = -3;
            }
        }
    }
    g_params.close(&file);
    if (buf) heap_free(heap, buf);
    /* 0 imported, 1 already imported, <0 failed: -1 read, -2 bad bundle,
       -3 marker write, -10 - n: entry n (retried next boot) */
    g_params.report("RR WiiVC: save import %d\n", status);
}

void rr_bootstrap(void) {
    g_params.report("RR WiiVC: bootstrap\n");

    int is_dol = 0;
    if (!g_code_buffer) {
        /* Mirror the RRLoadPack Riivolution memory patches. Only on the DOL pass:
           Code.pul later writes its own table over 0x80001800-0x80001BFF. */
        static const u32 cleared[] = {
            0x80001804, 0x800018A8, 0x80002370, 0x800023D0, 0x80002400,
            0x80002470, 0x800024A0, 0x800024E0, 0x80002510,
        };
        for (u32 i = 0; i < sizeof(cleared) / sizeof(cleared[0]); ++i)
            *(volatile u32 *)cleared[i] = 0;
        /* Retro Rewind's expected custom online region. */
        *(volatile u32 *)0x80005EFC = 10;
        /* Same as the pack's USB-loader main.dol: keep Pulsar saves on NAND. */
        *(volatile u32 *)0x800017D8 = 1;

        import_save_bundle();

        static const char path[] = "/Binaries/Code.pul";
        s32 entry = g_params.path_to_entry(path);
        if (entry < 0) fatal(LOAD_MISSING);

        DVDFileInfo file;
        if (!g_params.fast_open(entry, &file)) fatal(LOAD_OPEN);

        u32 sizes[8] __attribute__((aligned(32)));
        if (g_params.read_prio(&file, sizes, 32, 0, 2) < 0)
            fatal(LOAD_HEADER_READ);

        g_section_length = sizes[g_params.region];
        u32 rounded_length = round_up_32(g_section_length);
        void *heap = mem2_heap();
        if (heap) g_code_buffer = heap_alloc(heap, rounded_length, -0x20);
        if (!g_code_buffer) g_code_buffer = heap_alloc(system_heap(), rounded_length, -0x20);
        if (!g_code_buffer) fatal(LOAD_FILE_MEMORY);

        u32 offset = 16;
        for (u32 region = 0; region < g_params.region; ++region) offset += sizes[region];
        if (g_params.read_prio(&file, g_code_buffer, rounded_length, offset, 2) < 0)
            fatal(LOAD_BODY_READ);
        g_params.close(&file);
        is_dol = 1;
    }

    load_kamek(g_code_buffer, g_section_length, is_dol);
    if (!is_dol) heap_free(system_heap(), g_code_buffer);
}
