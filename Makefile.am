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
dist_completions_SCRIPTS= src/completions/unsafe-users.bash

## --------------------------------------------------------------------
## scripts

EXTRA_DIST		+= src/bin/unsafe-users.m4

dist_bin_SCRIPTS	= src/bin/unsafe-users

MBFLPP_FLAGS		= --preserve-comments

src/bin/unsafe-users : src/bin/unsafe-users.m4
	test -d src/bin || $(MKDIR_P) src/bin
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

CLEANFILES		= src/bin/unsafe-users

### end of file
