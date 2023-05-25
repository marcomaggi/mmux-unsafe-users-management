dnl @configure_input@
dnl

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([0],[5],[0],[devel.0],[noarch])
AC_INIT([MMUX Unsafe Users Management],MMUX_PACKAGE_VERSION,[mrc.mgg@gmail.com],
   [mmux-unsafe-users-management],
   [http://github.com/marcomaggi/mmux-unsafe-users-management/])
MMUX_INIT
dnl This is the revision number of this configure.ac
AC_REVISION([0.1])
AC_COPYRIGHT([Copyright (c) 2014, 2018, 2020, 2023 Marco Maggi <mrc.mgg@gmail.com>

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

MBFL_SETUP(v3.0.0-devel.8)


#### external programs

AC_PROG_SED

AC_ARG_WITH([bash],
  AS_HELP_STRING([--with-bash],[select a pathname for the executable bash]),
  [MMUX_PROGRAM_BASH=$withval],
  [MMUX_PROGRAM_BASH=/bin/bash])

dnl Remember  that  "AC_PATH_PROG"  already  calls  "AC_SUBST"  for  its
dnl variable argument.
AC_PATH_PROG([MMUX_PROGRAM_BASH],[$MMUX_PROGRAM_BASH],[/bin/false])

dnl --------------------------------------------------------------------

AC_ARG_WITH([useradd],
  AS_HELP_STRING([--with-useradd],[select a pathname for the executable useradd]),
  [MMUX_PROGRAM_USERADD=$withval],
  [MMUX_PROGRAM_USERADD=/usr/sbin/useradd])

dnl Remember  that  "AC_PATH_PROG"  already  calls  "AC_SUBST"  for  its
dnl variable argument.
AC_PATH_PROG([MMUX_PROGRAM_USERADD],[$MMUX_PROGRAM_USERADD],[/bin/false])

dnl --------------------------------------------------------------------

AC_ARG_WITH([userdel],
  AS_HELP_STRING([--with-userdel],[select a pathname for the executable userdel]),
  [MMUX_PROGRAM_USERDEL=$withval],
  [MMUX_PROGRAM_USERDEL=/usr/sbin/userdel])

dnl Remember  that  "AC_PATH_PROG"  already  calls  "AC_SUBST"  for  its
dnl variable argument.
AC_PATH_PROG([MMUX_PROGRAM_USERDEL],[$MMUX_PROGRAM_USERDEL],[/bin/false])

dnl --------------------------------------------------------------------

AC_ARG_WITH([usermod],
  AS_HELP_STRING([--with-usermod],[select a pathname for the executable usermod]),
  [MMUX_PROGRAM_USERMOD=$withval],
  [MMUX_PROGRAM_USERMOD=/usr/sbin/usermod])

dnl Remember  that  "AC_PATH_PROG"  already  calls  "AC_SUBST"  for  its
dnl variable argument.
AC_PATH_PROG([MMUX_PROGRAM_USERMOD],[$MMUX_PROGRAM_USERMOD],[/bin/false])

dnl --------------------------------------------------------------------

AC_ARG_WITH([groupadd],
  AS_HELP_STRING([--with-groupadd],[select a pathname for the executable groupadd]),
  [MMUX_PROGRAM_GROUPADD=$withval],
  [MMUX_PROGRAM_GROUPADD=/usr/sbin/groupadd])

dnl Remember  that  "AC_PATH_PROG"  already  calls  "AC_SUBST"  for  its
dnl variable argument.
AC_PATH_PROG([MMUX_PROGRAM_GROUPADD],[$MMUX_PROGRAM_GROUPADD],[/bin/false])

dnl --------------------------------------------------------------------

AC_ARG_WITH([groupdel],
  AS_HELP_STRING([--with-groupdel],[select a pathname for the executable groupdel]),
  [MMUX_PROGRAM_GROUPDEL=$withval],
  [MMUX_PROGRAM_GROUPDEL=/usr/sbin/groupdel])

dnl Remember  that  "AC_PATH_PROG"  already  calls  "AC_SUBST"  for  its
dnl variable argument.
AC_PATH_PROG([MMUX_PROGRAM_GROUPDEL],[$MMUX_PROGRAM_GROUPDEL],[/bin/false])

dnl --------------------------------------------------------------------

AC_ARG_WITH([groupmod],
  AS_HELP_STRING([--with-groupmod],[select a pathname for the executable groupmod]),
  [MMUX_PROGRAM_GROUPMOD=$withval],
  [MMUX_PROGRAM_GROUPMOD=/usr/sbin/groupmod])

dnl Remember  that  "AC_PATH_PROG"  already  calls  "AC_SUBST"  for  its
dnl variable argument.
AC_PATH_PROG([MMUX_PROGRAM_GROUPMOD],[$MMUX_PROGRAM_GROUPMOD],[/bin/false])


#### let's go

AC_CONFIG_FILES([Makefile]
  [meta/slackware/doinst.sh]
  [src/etc/mmux/xinitrc.d/mmux-unsafe-users-management.sh]
  [src/sbin/mmux-unsafe-users-manager.m4])
MMUX_OUTPUT
AC_OUTPUT

### end of file
