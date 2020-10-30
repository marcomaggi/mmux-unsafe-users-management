## Process this file with automake to produce Makefile.in

ACLOCAL_AMFLAGS		= -I meta/autotools
EXTRA_DIST		= INSTALL
dist_doc_DATA		= README COPYING
MBFLPP_FLAGS		= --add-bash
CLEANFILES		=


#### documentation

EXTRA_DIST		+= \
	doc/mmux-unsafe-users-management.style.css
CLEANFILES		+=						\
	doc/mmux-unsafe-users-management.css				\
	doc/mmux-unsafe-users-management.html/$(am__dirstamp)

AM_MAKEINFOFLAGS	= --no-split
AM_MAKEINFOHTMLFLAGS	= --split=node -c WORDS_IN_PAGE=0		\
	--css-ref=mmux-unsafe-users-management.css			\
	-c PRE_BODY_CLOSE="<p>This document describes version <tt>$(PACKAGE_VERSION)</tt> of <em>$(PACKAGE_NAME)</em>.</p>"

info_TEXINFOS		= doc/mmux-unsafe-users-management.texi
doc_mmux_unsafe_users_management_TEXINFOS	=			\
	doc/fdl-1.3.texi						\
	doc/gpl-3.0.texi						\
	doc/macros.texi

dist_man1_MANS		= doc/mmux-unsafe-users-manager.man

## --------------------------------------------------------------------

doc/mmux-unsafe-users-management.html/$(am__dirstamp): doc/$(am__dirstamp)
	@$(MKDIR_P) doc/mmux-unsafe-users-management.html/
	@: > doc/mmux-unsafe-users-management.html/$(am__dirstamp)

doc/mmux-unsafe-users-management.html/mmux-unsafe-users-management.css: \
		doc/mmux-unsafe-users-management.style.css doc/mmux-unsafe-users-management.html/$(am__dirstamp)
	$(INSTALL) -m 0444 \
		"$(top_srcdir)/doc/mmux-unsafe-users-management.style.css" \
		"$(builddir)/doc/mmux-unsafe-users-management.html/mmux-unsafe-users-management.css"

## --------------------------------------------------------------------

html-local: doc/mmux-unsafe-users-management.html/mmux-unsafe-users-management.css

install-html-local:
	$(MKDIR_P) "$(DESTDIR)$(htmldir)/mmux-unsafe-users-management.html/"
	$(INSTALL) -m 0444 \
		$(builddir)/doc/mmux-unsafe-users-management.html/mmux-unsafe-users-management.css \
		"$(DESTDIR)$(htmldir)/mmux-unsafe-users-management.html/"


#### scripts

EXTRA_DIST			+= 			\
	src/sbin/mmux-unsafe-users-manager.m4

sbin_SCRIPTS			= 			\
	src/sbin/mmux-unsafe-users-manager

CLEANFILES			+=	 		\
	src/sbin/mmux-unsafe-users-manager		\
	src/sbin/$(am__dirstamp)

sbinscripts_PREREQUISITES	=			\
	src/sbin/$(am__dirstamp)

src/sbin/$(am__dirstamp):
	@$(MKDIR_P) src/sbin/
	@: > src/sbin/$(am__dirstamp)

src/sbin/mmux-unsafe-users-manager :			\
		src/sbin/mmux-unsafe-users-manager.m4	\
		$(sbinscripts_PREREQUISITES)
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@


#### sudoers files

sudoersdir		= $(sysconfdir)/sudoers.d
dist_sudoers_DATA	= src/etc/sudoers.d/mmux-unsafe-users-management.conf


#### command line completions

completionsdir			= $(sysconfdir)/bash_completion.d
completions_SCRIPTS		= \
	src/etc/bash_completion.d/mmux-unsafe-users-manager.bash

CLEANFILES			+= \
	src/etc/bash_completion.d/mmux-unsafe-users-manager.bash

completions_PREREQUISITES	= \
	src/etc/bash_completion.d/$(am__dirstamp)

src/etc/bash_completion.d/$(am__dirstamp):
	@$(MKDIR_P) src/etc/bash_completion.d
	@: > src/etc/bash_completion.d/$(am__dirstamp)

src/etc/bash_completion.d/mmux-unsafe-users-manager.bash: src/sbin/mmux-unsafe-users-manager $(completions_PREREQUISITES)
	$(BASH_PROGRAM) src/sbin/mmux-unsafe-users-manager help print-completions-script >$(@)


#### X11 interface

mmuxX11dir		= $(sysconfdir)/mmux/xinitrc.d
dist_mmuxX11_SCRIPTS	= src/etc/mmux/xinitrc.d/mmux-unsafe-users-management.sh

### end of file
