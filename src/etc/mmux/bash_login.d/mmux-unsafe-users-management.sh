#!/bin/bash
# /etc/mmux/bash_login.d/mmux-unsafe-users-management.sh --
#
# Login script, to be executed  at user login-time by "~/.bash_login" or
# similar scripts.  Sets up support for unsafe user accounts managed
# by the package MMUX Unsafe Users Management.

SCRIPT=/usr/sbin/mmux-unsafe-users-manager

if test -x "$SCRIPT"
then "$SCRIPT" bind --verbose
else printf '%s: script file not found: %s\n' "$0" "$SCRIPT" >&2
fi

### end of file
