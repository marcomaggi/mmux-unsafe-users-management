#!/bin/sh
# configure.sh --
#
# Run this to configure.

set -xe

prefix=/usr

../configure \
    --enable-maintainer-mode			\
    --config-cache                              \
    --cache-file=../config.cache                \
    --prefix="${prefix}"                        \
    --sysconfdir=/etc                           \
    "$@"

### end of file
