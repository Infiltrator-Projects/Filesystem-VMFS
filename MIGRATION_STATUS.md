# VMFS Common V2 migration status

## Source and ownership

[Exact central baseline](https://github.com/Infiltrator-Projects/Filesystems/tree/101026021d9088d80b7f0f472d9061f0e2c688a3/native/filesystems/vmfs). Design-only central entry; no implementation to extract. External vmfs-tools may be used as independent read-only evidence, not a target runtime. Establish a documented native implementation with verifiable source provenance; do not claim an existing engine. New project-authored code uses GPL-3.0-or-later. No source transferred by this documentation commit.

## Qualification plan

1. Enumerate supported on-disk variants, validate geometry and features; implement bounded CORE probe.
2. Provide CORE mount/stat/list/read and VOLUME query using native volume and extent geometry, metadata records, inode/file mapping, directories, allocation and cluster lock state.
3. Test independently produced VMFS3 and VMFS5 images; reject VMFS6, incomplete extents, ambiguous versions and unqualified lock state; compare independent payloads and unchanged-image hashes; inject malformed media and I/O faults.
4. Implement mutation, format, check/repair and DEFRAG map/plan/execute/verify/recover only with proven allocation, durability and interruption/recovery semantics. Shared-disk writes additionally require independently qualified cluster locking and ownership. Unsupported operations must refuse before writing.
5. Qualify exact packaged Common V2 ABI, hosted and import-free freestanding profiles, then actual BOOT and kernel integration independently.

All independent stages, PDF manual and packaging are pending. No runtime capability is claimed.
