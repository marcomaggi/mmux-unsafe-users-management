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

dist_man1_MANS		= doc/mmux-unsafe-users-manager.man

## --------------------------------------------------------------------

sudoersdir		= $(sysconfdir)/sudoers.d
dist_sudoers_DATA	= src/etc/sudoers.d/mmux-unsafe-users-management.conf

## --------------------------------------------------------------------

completionsdir		= $(sysconfdir)/bash_completion.d
dist_completions_SCRIPTS= src/etc/bash_completion.d/mmux-unsafe-users-manager.bash

## --------------------------------------------------------------------

mmuxX11dir		= $(sysconfdir)/mmux/xinitrc.d
dist_mmuxX11_SCRIPTS	= src/etc/mmux/xinitrc.d/mmux-unsafe-users-management.sh

## --------------------------------------------------------------------
## scripts

EXTRA_DIST		+= src/sbin/mmux-unsafe-users-manager.m4

dist_sbin_SCRIPTS	= src/sbin/mmux-unsafe-users-manager

MBFLPP_FLAGS		= --add-bash

src/sbin/mmux-unsafe-users-manager : src/sbin/mmux-unsafe-users-manager.m4
	test -d src/sbin || $(MKDIR_P) src/sbin
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

CLEANFILES		= src/sbin/mmux-unsafe-users-manager

### end of file
