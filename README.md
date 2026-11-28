# Filesystem-VMFS

Independent native Common V2 offline reader development. VMFS3/5 32-bit direct block IDs and flat directory records. The reader bootstraps the actual FDC and FBB metadata files, reconstructs file-block allocation and reconciles descriptor identities before serving CORE stat/list/read. Only bounded single-extent direct file blocks and inline content are implemented; subblock and indirect schemes, RDM, multi-extent, locked metadata, mutation and recovery are refused. The captured upstream VMFS3 image is a mandatory independent namespace qualification; VMFS5 independent media is still unavailable. No physical BOOT or kernel qualification. The current v0.0.1 release remains documentation-only pending exact-source runtime qualification.

[Manual](docs/VMFS.pdf) · [Technical reference](docs/VMFS-TECHNICAL-REFERENCE.md) · [Migration status](MIGRATION_STATUS.md) · [Common V2](https://github.com/Infiltrator-Projects/Libraries)
