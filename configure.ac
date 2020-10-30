dnl @configure_input@
dnl

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([0],[4],[0],[devel.0],[noarch])
AC_INIT([MMUX Unsafe Users Management],MMUX_PACKAGE_VERSION,[marco.maggi-ipsu@poste.it],
   [mmux-unsafe-users-management],[http://github.com/marcomaggi/mmux-unsafe-users-management/])
MMUX_INIT
AC_CONFIG_SRCDIR([src])
AC_CONFIG_MACRO_DIR([meta/autotools])
AC_CONFIG_AUX_DIR([meta/autotools])
AM_INIT_AUTOMAKE([1.14 foreign subdir-objects info-in-builddir])
AM_MAINTAINER_MODE

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P

MBFL_SETUP

AC_CONFIG_FILES([Makefile]
  [meta/slackware/doinst.sh])
MMUX_OUTPUT
AC_OUTPUT

### end of file
