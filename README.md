# Filesystem-VMFS

Independent native Common V2 offline reader development. VMFS3 32-bit direct block IDs and flat directory records. The reader bootstraps the actual FDC and FBB metadata files, reconstructs file-block allocation and reconciles descriptor identities before serving CORE stat/list/read. Only bounded single-extent direct file blocks and inline content are implemented; subblock and indirect schemes, RDM, multi-extent, locked metadata, mutation and recovery are refused. The captured upstream VMFS3 image is a mandatory independent namespace qualification; VMFS5 is recognition-only pending independent media. No physical BOOT or kernel qualification. The v0.1.0 candidate is gated on captured VMFS3 media, structural payload fixtures, sanitizers and native package verification. VMFS5 mounts are refused pending genuine independent media. The v0.0.1 PDF-only release remains immutable.

[Manual](docs/VMFS.pdf) · [Technical reference](docs/VMFS-TECHNICAL-REFERENCE.md) · [Migration status](MIGRATION_STATUS.md) · [Common V2](https://github.com/Infiltrator-Projects/Libraries)

[Development qualification 46132534251](https://github.com/Infiltrator-Projects/Filesystem-VMFS/actions/runs/46132534251) passed captured VMFS3 namespace, populated structural payload and sanitizer tests. Runtime publication is gated on the exact new revision.
