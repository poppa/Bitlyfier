NULL = 

#Build in these directories:

SUBDIRS = \
	src \
	po \
	$(NULL)

bitlyfierdocdir = ${prefix}/doc/bitlyfier
bitlyfierdoc_DATA = \
	ChangeLog \
	README \
	COPYING \
	AUTHORS \
	INSTALL \
	NEWS\
	$(NULL)

EXTRA_DIST = \
	$(bitlyfierdoc_DATA) \
	intltool-extract.in \
	intltool-merge.in \
	intltool-update.in\
	$(NULL)

DISTCLEANFILES = \
	intltool-extract \
	intltool-merge \
	intltool-update \
	po/.intltool-merge-cache \
	$(NULL)

