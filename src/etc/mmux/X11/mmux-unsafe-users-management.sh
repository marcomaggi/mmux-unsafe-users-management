#!/bin/sh
# /etc/mmux/X11/mmux-unsafe-users-management.sh --
#
# Allow selected unsafe users to run processes under X11.


SCRIPT=/usr/bin/mmux-unsafe-users

if test -x "$SCRIPT"
then "$SCRIPT" enable-x --verbose
else printf '%s: script file not found: rc.unsafe-users\n' "$0" "$SCRIPT" >&2
fi

### end of file
