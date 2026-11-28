# VMFS Common V2 migration

Native single-extent VMFS3/5 geometry, LVM UUID, FDC allocation bitmap and allocated root descriptor validation. VMFS3 upstream captured media included; VMFS5 only structural fixtures so far.

The native C implementation uses Common V2 bounded host I/O only. It is not a kernel, FUSE or external tool adapter. Test tools are independent oracles only. Constructed metadata fixtures, malformed-media rejection, hosted and import-free builds and sanitizers are defined in CI. Exact-source results establish the qualification boundary. Native namespace, allocation ownership beyond the decoded structures, journal or distributed-lock semantics, writes, repair, formatting and defragmentation remain outstanding. Runtime release is not yet authorized by these checks.

## Native direct namespace development

CORE mount/stat/list/read and VOLUME query now implement bounded offline FDC/FBB bootstrap and allocation-checked direct reads. Populated structural fixtures exercise real descriptor and bitmap paths, including refusal of free-block payloads and mismatched bitmap counts. Captured VMFS3 image must pass the new namespace tests; genuine VMFS5 media remains outstanding. No runtime publication until independent qualification. Subblock, pointer blocks, distributed locking, mutation, recovery and physical integration are outstanding.

Captured VMFS3 and populated structural tests passed in [46132534251](https://github.com/Infiltrator-Projects/Filesystem-VMFS/actions/runs/46132534251). VMFS5 mount is now explicitly refused pending genuine media; native release CI qualifies the exact new revision.

### Mounted volume lifetime

The provider copies the caller's size-versioned host descriptor and assigns each mount an opaque generation. An operation reserves its mount until its callback returns. A concurrent unmount or second operation on that mount returns `IFS_FS_BUSY`. Independent mounts remain usable. Unmount removes the generation before releasing native state, so a closed handle returns `IFS_FS_INVALID` even after a new mount reuses the same memory. The Common V2 regression holds a directory read inside a host I/O callback while a second thread queries and unmounts both volumes.
