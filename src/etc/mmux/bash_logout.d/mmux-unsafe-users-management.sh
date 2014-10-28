#!/bin/bash
# /etc/mmux/bash_logout.d/mmux-unsafe-users-management.sh --
#
# Logout script, to be executed  at user logout-time by "~/.bash_logout"
# or  similar  scripts.  Sets  down  support  for unsafe  user  accounts
# managed by the package MMUX Unsafe Users Management.

SCRIPT=/usr/sbin/mmux-unsafe-users-manager

if test -x "$SCRIPT"
then "$SCRIPT" unbind --verbose
else printf '%s: script file not found: %s\n' "$0" "$SCRIPT" >&2
fi

### end of file
