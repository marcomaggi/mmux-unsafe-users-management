## Process this file with automake to produce Makefile.in

ACLOCAL_AMFLAGS		= -I meta/autotools
EXTRA_DIST		= INSTALL configure.sh
dist_doc_DATA		= README COPYING

## --------------------------------------------------------------------

AM_MAKEINFOFLAGS	= --no-split

info_TEXINFOS		= doc/mmux-unsafe-users-management.texi
doc_mmux_unsafe_users_management_TEXINFOS	= \
	doc/fdl-1.3.texi			\
	doc/gpl-3.0.texi			\
	doc/macros.texi

## --------------------------------------------------------------------

sudoersdir		= $(sysconfdir)/sudoers.d
dist_sudoers_DATA	= src/etc/sudoers.d/mmux-unsafe-users-management.conf

## --------------------------------------------------------------------

completionsdir		= $(sysconfdir)/bash_completion.d
dist_completions_SCRIPTS= src/completions/mmux-unsafe-users.bash

## --------------------------------------------------------------------

mmuxbashlogindir		= $(sysconfdir)/mmux/bash_login.d
dist_mmuxbashlogin_SCRIPTS	= src/etc/mmux/bash_login.d/mmux-unsafe-users-management.sh

mmuxbashlogoutdir		= $(sysconfdir)/mmux/bash_logout.d
dist_mmuxbashlogout_SCRIPTS	= src/etc/mmux/bash_logout.d/mmux-unsafe-users-management.sh

mmuxX11dir			= $(sysconfdir)/mmux/xinitrc.d
dist_mmuxX11_SCRIPTS		= src/etc/mmux/xinitrc.d/mmux-unsafe-users-management.sh

## --------------------------------------------------------------------
## scripts

EXTRA_DIST		+= src/sbin/mmux-unsafe-users.m4

dist_sbin_SCRIPTS	= src/sbin/mmux-unsafe-users

MBFLPP_FLAGS		= --preserve-comments

src/sbin/mmux-unsafe-users : src/sbin/mmux-unsafe-users.m4
	test -d src/sbin || $(MKDIR_P) src/sbin
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

CLEANFILES		= src/bin/mmux-unsafe-users

### end of file
