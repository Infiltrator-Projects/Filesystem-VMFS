# VMFS: technical reference

## Scope, history and source

VMware VMFS is a clustered datastore filesystem used to store virtual-machine disks, configuration and other files on shared storage. This chapter treats the VMFS3 and VMFS5 layouts separately from VMFS6. VMFS5 introduced a unified block-size strategy for newly formatted volumes and expanded scalability; upgraded volumes may retain older geometry. The field-level evidence is Christophe Fillot and Mike Hommey's reverse-engineered vmfs-tools, commit 4ab76ef5b074bdf06e4b518ff6d50439de05ae7f. Its volume reader accepts versions 3 and 5 and explicitly restricts VMFS5 write access. The following is not an official complete vendor on-disk specification.

VMFS3 and VMFS5 are historical datastore generations; do not infer their shared-storage locking from VMFS6 or ordinary local filesystems.

## Physical volume and filesystem information

The observed partition-relative volume information begins at 0x100000, with little-endian magic 0xC001D00D at offset 0 and 32-bit volume version at 4. LUN byte is at 14, 28-byte name at 18, 32-bit physical-size field at 95 and 16-byte volume UUID at 130. The reference describes the physical-size field as scaled by 256; validate its unit against known media. The filesystem address space starts 0x1000000 bytes after the volume-information base. Within the assembled logical volume, filesystem information begins at 0x200000 and has magic 0x2FABF15E. For a single partition and first extent beginning at segment zero, that corresponds to partition byte 0x1300000. For a whole-disk image, add the actual partition start. Validate partition boundaries rather than assuming a legacy MBR.

## Filesystem information field inventory

Relative to the filesystem information record: magic 0, volume version 4, one-byte filesystem version 8, 16-byte UUID 9, mode 25, 128-byte label 29, device-block-size field 157, 64-bit filesystem block size 161, 32-bit creation-time field 169, unknown four bytes 173, LVM UUID 177, unknown sixteen bytes 193, FDC header size 209, FDC bitmap count 213 and subblock size 217. Decode fixed-width little-endian numbers without assuming host structure alignment. Verify sizes, member identity, version and metadata geometry before using block addressing. Preserve the unknown fields; the timestamp interpretations are reference observations rather than a complete vendor specification.

## Logical-volume extent assembly

The LVM information contains total logical size and block-count fields at relative offsets 0 and 8, textual UUID at 20 (35 bytes), binary UUID at 84, creation-time field 104, number of segments 116, first segment 120, last segment 128, modification-time field 136 and extent count 144. The reference maps extents in 256 MiB segments, with inclusive first and last segment numbers. For logical byte p, choose the member covering floor(p/268435456); its data-relative offset is p minus first_segment times 268435456. Add the member's actual volume base and data prefix. Split cross-member reads. Validate UUIDs, complete nonoverlapping coverage, member sizes and arithmetic; a missing member is not a sparse file hole.

## VMFS3/5 extent header and root discovery

For this reference, the LVM record begins 0x200 bytes after volume information. The logical heartbeat area begins at 0x300000 and contains 2048 records of 512 bytes. The reference computes its initial FDC bootstrap block as max(1, floor((0x300000+2048*512)/filesystem_block_size)). It opens a temporary one-block metadata mapping at that position, obtains descriptor entry 0, item 0 as the root, then resolves the actual allocator files by name from that directory. The bootstrap is an observed reader strategy and must be corroborated on authentic volumes; do not confuse the temporary descriptor with a stored inode.

## Metadata ownership header

The decoded common prefix holds magic at 0 (32 bits), logical object position at 4 (64 bits), heartbeat position at 12, heartbeat sequence at 20, object sequence at 28, lock indicator at 36 (32 bits), 16-byte locking-host UUID at 40 and modification-time field at 56 (64 bits). Remaining header bytes are not fully interpreted by the reference. Validate object identity, expected magic and address space; keep position, lock state and timestamps separate. Heartbeat records use observed active/inactive magic values 0xABCDEF02 and 0xABCDEF01. Never clear locks, declare another host dead, or treat a storage reservation as sufficient proof of exclusive ownership merely from these fields.

## File descriptor fields

Offsets relative to the end of the metadata header are: ID 0, second ID 4, link count 8, file type 12, flags 16, 64-bit logical byte length 20, allocation block size 28, block count 36, then 32-bit mtime 44, ctime 48, atime 52, UID 56, GID 60, mode 64, allocation scheme (ZLA) 68, to-be-zeroed field 72, copy-on-write field 76 and unknown bytes 80..511. The descriptor magic is 0x10C00001. File type and allocation scheme determine whether the subsequent union contains inline bytes, encoded allocation references or a raw-device mapping identifier. Raw-device mappings are not ordinary resident payload. Validate size, pointer capacity and mode rather than trusting a plausible inode signature.

## VMFS3/5 descriptor and block IDs

Metadata headers occupy 512 bytes, file descriptors 2048 bytes. The allocation union begins at descriptor byte 1024 and holds 256 little-endian 32-bit block IDs or 1024 inline bytes. Block type is bits 0..2: 0 absent, 1 file block, 2 subblock, 3 pointer block and 4 file descriptor. File-block item is bits 6..31; flags 3..5, with flag value 4 indicating to-be-zeroed. Pointer-block entry is bits 6..27 and item bits 28..31. Descriptor entry is bits 6..21 and item bits 22..31. Subblock entry occupies bits 6..27, item low four bits are in 28..31 and high two bits in 3..4; bit 5 is a flag of uncertain semantics. Decode each type separately.

## Allocation catalogue principles

The filesystem uses metadata files for file blocks (.fbb.sf), subblocks (.sbc.sf), pointer blocks (.pbc.sf) and file descriptors (.fdc.sf). Their magic values are 0x10C00002 through 0x10C00005 respectively. A bitmap file's header describes items per entry, bitmap entries per area, header size, item-data size, area size, total items and area count. Allocation entries contain a common ownership header followed by entry ID, total item count, free count, first-free hint and 496 bitmap bytes in the observed format. The pinned VMFS3/5 implementation uses set bits for free items and clear bits for allocated items; verify that convention for each admitted revision. Counts and first-free hints must agree with validated bits. Check unused tail bits and metadata ownership before allocation.

## Bitmap item address calculation

Let I be items per bitmap entry, E entries per area, H header size, A area size, D data bytes per item and S persistent bitmap-entry stride. A requested entry e and item i map to n=e*I+i. Area is floor(n/(I*E)), and the item position within the bitmap file is H+area*A+E*S+(n modulo (I*E))*D. These are file-relative addresses, not raw disk locations. Resolve the metadata file's own mapping before reading. In the observed bitmap, the local item index selects byte floor(index/8) and bit index modulo 8. Reject zero sizes, overflows, item indexes beyond the last entry and self-referential metadata chains.

## VMFS3/5 file lookup and worked example

ZLA selects direct file/subblock mapping or pointer-block mapping; the reference subtracts 4301 for its observed VMFS5 extended encoding. For direct mapping, divide logical byte offset by inode block size and select the indexed descriptor entry. For a pointer-block array containing P bytes, there are P/4 references; divide the logical block index by that count to select the primary pointer and use the remainder to select its entry. Resolve the pointer object through PBC metadata. For an ordinary file-block ID 0x00001901, type is 1 and item is 100. If filesystem block size is 1 MiB, the logical-volume byte position is 104857600 plus the intra-block offset. Unallocated or to-be-zeroed storage must not reveal residual physical contents. Inline extended descriptors and RDM objects require distinct treatment.

## VMFS3/5 directory organisation

A directory is a file containing fixed 140-byte records (0x8C). Record fields are 32-bit type at 0, block ID at 4, record ID at 8 and 128 name bytes at 12. Record n starts at n*140 relative to the directory file. A reader resolves the descriptor using the type-specific block ID, validates record bounds and compares bounded names. Interpret dot and dot-dot entries and symbolic references with loop bounds. Check each directory target against the descriptor ID and link count. Do not use this flat layout for VMFS6; that generation has different directory records and page metadata.

## Integrity and shared-storage semantics

VMFS is designed for simultaneous access by hypervisor hosts. Logical ownership, distributed metadata locks, heartbeats, fencing and recovery ordering are critical; a static image reader is not a cluster participant. A stable offline image can be checked by comparing descriptor identities, directory links, allocation bitmaps, pointer blocks, actual payload coverage and all member boundaries. Record contradictions without modifying the source. VMDK descriptor and snapshot/delta-chain formats sit above VMFS and are distinct from filesystem allocation metadata. Do not infer VMFS journal replay, lock expiry, atomic update or reclamation rules from a VMDK parser.

## Writer and defragmentation boundary

An independent writer requires exact native allocation transitions, metadata update ordering, durable flush and recovery semantics, and proven exclusion of every other host. Moving a file block changes its ownership and every reference; subblock and pointer-block relocation also changes catalogue metadata. An apparent free bitmap bit alone does not authorise reuse while another host may hold a valid reference. Formatting must establish coherent extent metadata, filesystem information, root descriptor, allocator catalogues, heartbeats and recovery state. The available reverse-engineering evidence does not establish complete native formatting, journal replay, distributed write or repair algorithms. Treat those operations as unqualified until they are independently demonstrated.

## Implementation and qualification boundary

The original central design record contained no VMFS3/5 engine. The independent vmfs-tools reference now supplies version-specific reader evidence; it remains a test oracle, not a production fallback. Multi-extent and shared-lock mutation require separate evidence.

Common V2 is the independent provider interface: https://github.com/Infiltrator-Projects/Libraries/blob/main/docs/FILESYSTEM_COMMON_ABI_V2.md . Negotiate real operation masks and media profiles. Use bounded host I/O, exclusive unmounted ownership and durable flush for mutation; distinguish unsupported, corrupt, I/O and stale-handle results. Test Media and Defragmenter use the same engine. Hosted, freestanding, BOOT, kernel, recovery and package qualification are independent. Current capability and release status belongs to the repository README and exact-source qualification records; historical evidence is not a current status claim.

Historical source or test reference: https://github.com/Infiltrator-Projects/Filesystems/tree/101026021d9088d80b7f0f472d9061f0e2c688a3/native/filesystems/vmfs .

## References and qualification

Pinned source: https://github.com/glandium/vmfs-tools/tree/4ab76ef5b074bdf06e4b518ff6d50439de05ae7f/libvmfs . Relevant files are vmfs_volume.c, vmfs_lvm.c, vmfs_fs.c, vmfs_metadata.h, vmfs_inode.c, vmfs_block.h, vmfs_bitmap.c and vmfs_dirent.c. Compare independently formatted VMFS3, VMFS5 and upgraded images against matching native host tools and a read-only reference. Test missing or overlapping extents, corrupt block IDs, invalid bitmap geometry, pointer-depth limits, zeroed allocation, inline files and locked metadata. A useful reader requires exact admitted bitmap and allocation schemes; complete original write and recovery documentation remains an open research requirement.
