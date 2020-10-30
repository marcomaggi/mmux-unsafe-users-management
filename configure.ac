dnl @configure_input@
dnl

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([0],[4],[0],[devel.1],[noarch])
AC_INIT([MMUX Unsafe Users Management],MMUX_PACKAGE_VERSION,[mrc.mgg@gmail.com],
   [mmux-unsafe-users-management],
   [http://github.com/marcomaggi/mmux-unsafe-users-management/])
MMUX_INIT
dnl This is the revision number of this configure.ac
AC_REVISION([0.1])
AC_COPYRIGHT([Copyright (c) 2014, 2018, 2020 Marco Maggi <mrc.mgg@gmail.com>

This is  free software; you can  redistribute it and/or modify  it under
the terms  of the GNU  General Public License  as published by  the Free
Software  Foundation; either  version 3.0  of the  License, or  (at your
option) any later version.

This library  is distributed  in the  hope that it  will be  useful, but
WITHOUT   ANY   WARRANTY;  without   even   the   implied  warranty   of
MERCHANTABILITY  or  FITNESS FOR  A  PARTICULAR  PURPOSE.  See  the  GNU
General Public License for more details.

You should have received a copy  of the GNU General Public License along
with this library; if not, write  to the Free Software Foundation, Inc.,
59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
])
AC_CONFIG_SRCDIR([src])
AC_CONFIG_MACRO_DIR([meta/autotools])
AC_CONFIG_AUX_DIR([meta/autotools])
AM_INIT_AUTOMAKE([1.14 foreign subdir-objects info-in-builddir])
AM_MAINTAINER_MODE

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P

AC_CHECK_PROG([BASH_PROGRAM],[bash],[bash],[:])
MBFL_SETUP

AC_CONFIG_FILES([Makefile]
  [meta/slackware/doinst.sh]
  [src/etc/mmux/xinitrc.d/mmux-unsafe-users-management.sh])
MMUX_OUTPUT
AC_OUTPUT

### end of file
