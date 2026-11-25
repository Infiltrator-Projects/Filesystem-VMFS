# VMFS — native filesystem design

## Format scope

VMware VMFS3/VMFS5; VMFS6 belongs to its own repository. This is a design contract, not a claim of implemented capabilities.

## On-disk structures and ownership

Document supported versions and independently establish volume/extent geometry, metadata records, inode/file mappings, namespace, allocation, distributed ownership and journal semantics. The single native C/C++ engine owns these format semantics; consumers provide bounded Common V2 host services, never competing parsers.

## Integrity and mutation invariants

Reject unknown layouts, incomplete extent sets, contradictory ownership and unsafe journal states. Shared-disk mutation requires proven distributed locking, fencing and recovery; do not infer write support from external read-only access. All arithmetic, offsets and lengths are checked before I/O. Writable operations require exclusive access, explicit ordering, flush and interruption/recovery evidence. Read-only operations leave the medium unchanged.

## Common V2 boundary

Only `infiltrator_filesystem_api_v2` is public. Target the genuine PROBE/MOUNT/UNMOUNT/STAT/LIST/READ operations first; negotiate actual supported operation masks. VOLUME, METADATA and DEFRAG operations (including MAP, PLAN, EXECUTE, VERIFY, RECOVER) are individually qualified or refused. Test Media uses the same provider's qualified format and namespace operations. No FUSE, legacy ABI, private driver or kernel proxy. Hosted and import-free freestanding profiles share the format engine, with generic environment-specific host services.

## Qualification

Use independently produced VMFS3/VMFS5 images and vmfs-tools as an independent reader where compatible. Test missing extents, malformed metadata and version refusal; VMFS6 must not be silently accepted. Compare file bytes against an independent oracle, hash unchanged read-only images, inject short I/O, corruption and interruption; validate exact published module separately in BOOT and kernel. Use disposable media only. No new independent binary or test pass is claimed.

## Source and migration

[Central source and historical design, pinned revision](https://github.com/Infiltrator-Projects/Filesystems/tree/101026021d9088d80b7f0f472d9061f0e2c688a3/native/filesystems/vmfs). The central entry is design-only; acquire and validate appropriately licensed source or implement against documented on-disk evidence. Do not claim that an existing engine has been extracted. New project-authored code uses GPL-3.0-or-later. See [migration status](../../../MIGRATION_STATUS.md), [philosophy](../../../docs/PHILOSOPHY.md) and [Common V2 contract](https://github.com/Infiltrator-Projects/Libraries/blob/main/docs/FILESYSTEM_COMMON_ABI_V2.md). Source migration is a separate step.
