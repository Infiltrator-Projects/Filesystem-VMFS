#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Keep the firmware baseline independent of host-native compiler flags.
set -eu
case "$1" in
    portable) flags='-O2 -march=x86-64 -mtune=generic';;
    aggressive) flags='-O3 -march=native -flto';;
    *) exit 2;;
esac
test "$(git hash-object Libraries/include/infiltratr/filesystem_module_v2.h)" = 90730b68a53ecf6a6e304c789501f29c17c728c7
make clean
make CFLAGS="$flags" check
# The hosted provider is installed; import-free development tests do not qualify firmware.
sh scripts/package.sh "$2"
