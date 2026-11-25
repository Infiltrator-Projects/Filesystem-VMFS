# Filesystem-VMFS

Independent VMware VMFS3/VMFS5 shared-disk filesystem provider for InfiltratorOS. Target: one native C/C++ engine and one distributable `VMFS.so`.

**Status: documentation only; implementation pending.** [Central source/design](https://github.com/Infiltrator-Projects/Filesystems/tree/101026021d9088d80b7f0f472d9061f0e2c688a3/native/filesystems/vmfs). Design-only central entry; no implementation to extract. External vmfs-tools may be used as independent read-only evidence, not a target runtime. No independent driver or release exists.

## Common V2

Use only `infiltrator_filesystem_api_v2` from [Libraries](https://github.com/Infiltrator-Projects/Libraries). Own volume and extent geometry, metadata records, inode/file mapping, directories, allocation and cluster lock state in the same engine for hosted and freestanding execution. No FUSE, separate per-format kernel/EFI driver or legacy ABI.

## Build and install

Planned: `/System/Filesystems/VMFS.so` and `/System/Resources/Documentation/Filesystem-VMFS.pdf`. Generic amd64 .deb, source-downloading CPU-native .run and GitHub-generated source ZIP only. No build or installer exists yet.

See [migration status](MIGRATION_STATUS.md) and [engineering philosophy](docs/PHILOSOPHY.md).
