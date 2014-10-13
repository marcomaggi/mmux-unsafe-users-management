#!/bin/bash
# /etc/mmux/bash_login.d/mmux-unsafe-users-management.sh --
#
# Login script.  Sets up support for unsafe user accounts managed
# by the package MMUX Unsafe Users Management.

SCRIPT=/usr/bin/mmux-unsafe-users

if test -x "$SCRIPT"
then "$SCRIPT" bind --verbose
else printf '%s: script file not found: rc.unsafe-users\n' "$0" "$SCRIPT" >&2
fi

### end of file
