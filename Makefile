# SPDX-License-Identifier: GPL-3.0-or-later
CC ?= cc
CFLAGS ?= -O2
BASE = -std=c11 -Wall -Wextra -Werror -I Libraries/include
SRC = native/filesystems/vmfs/vmfs.c
HDR = native/filesystems/vmfs/reader.h Libraries/include/infiltratr/filesystem_session_v2.h
.PHONY: all check clean
all: build/VMFS.so build/freestanding/VMFS.so
build/VMFS.so: $(SRC) $(HDR) Makefile
	mkdir -p build
	$(CC) $(BASE) $(CFLAGS) -fPIC -fvisibility=hidden -shared -Wl,-z,defs -o $@ $(SRC)
build/freestanding/VMFS.so: $(SRC) $(HDR) Makefile
	mkdir -p build/freestanding
	$(CC) $(BASE) -O2 -march=x86-64 -DIFS_FREESTANDING -ffreestanding -fno-builtin -fno-stack-protector -fno-tree-loop-distribute-patterns -fPIC -fvisibility=hidden -shared -nostdlib -Wl,-z,defs,-Bsymbolic -o $@ $(SRC)
build/test_vmfs: tests/test_vmfs.c Libraries/tests/filesystem_reader_lifetime.h
	mkdir -p build
	$(CC) $(BASE) $(CFLAGS) -o $@ $< -ldl -pthread
check: all build/test_vmfs
	test "$$(nm -D --defined-only build/VMFS.so | awk '{print $$3}')" = infiltrator_filesystem_api_v2
	test "$$(nm -D --defined-only build/freestanding/VMFS.so | awk '{print $$3}')" = infiltrator_filesystem_api_v2
	test -z "$$(nm -D --undefined-only build/freestanding/VMFS.so)"
	! readelf -d build/freestanding/VMFS.so | grep -q NEEDED
	build/test_vmfs ./build/VMFS.so
	build/test_vmfs ./build/freestanding/VMFS.so
clean:
	rm -rf build
