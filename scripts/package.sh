#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# One package owns the tested hosted carrier and its reference manual.
set -eu
name=VMFS
slug=vmfs
module=VMFS
version=$(cat VERSION)
dpkg --validate-version "$version"
out=$(realpath -m "${1:-dist}")
mkdir -p "$out"
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT HUP INT TERM
pdf="docs/$name.pdf"
so="build/$module.so"
test -s "$pdf"
test "$(head -c 5 "$pdf")" = '%PDF-'
test -s "$so"
test "$(nm -D --defined-only "$so" | awk '{print $3}')" = infiltrator_filesystem_api_v2
install -Dm755 "$so" "$stage/System/Filesystems/$module.so"
install -Dm644 "$pdf" "$stage/System/Resources/Documentation/Filesystem-$name.pdf"
mkdir -p "$stage/DEBIAN"
cat > "$stage/DEBIAN/control" <<EOF
Package: infiltrator-filesystem-$slug
Version: $version
Architecture: amd64
Maintainer: Infiltrator Projects
Section: utils
Priority: optional
Description: $name Common V2 filesystem provider and reference PDF
 Supported operations are limited to the provider's actual advertised capabilities.
EOF
dpkg-deb --build --root-owner-group "$stage" "$out/infiltrator-filesystem-${slug}_${version}_amd64.deb"
