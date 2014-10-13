#!/bin/bash
# /etc/mmux/bash_logout.d/mmux-unsafe-users-management.sh --
#
# Logout script.  Sets up support for unsafe user accounts managed
# by the package MMUX Unsafe Users Management.

SCRIPT=/usr/sbin/mmux-unsafe-users

if test -x "$SCRIPT"
then "$SCRIPT" unbind --verbose
else printf '%s: script file not found: rc.unsafe-users\n' "$0" "$SCRIPT" >&2
fi

### end of file
