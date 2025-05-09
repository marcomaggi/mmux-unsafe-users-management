#!/bin/sh
# configure.sh --
#
# Run this to configure.

set -xe

# Installing under root is safer.
prefix=/

../configure \
    --enable-maintainer-mode			\
    --config-cache                              \
    --cache-file=./config.cache                 \
    --prefix="${prefix}"                        \
    --sysconfdir=/etc                           \
    "$@"

### end of file
