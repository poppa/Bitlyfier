NULL = 

AM_CPPFLAGS = \
	$(BITLYFIER_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

bin_PROGRAMS = bitlyfier

bitlyfier_SOURCES = \
	application.vala \
	mainwindow.vala \
	bitly.vala \
	main.vala \
	$(NULL)

bitlyfier_VALAFLAGS = \
	--thread \
	--pkg=gtk+-2.0 \
	--pkg=gconf-2.0 \
	--pkg=gee-1.0 \
	--pkg=libsoup-2.4 \
	--pkg=json-glib-1.0 \
	--pkg=config \
	--vapidir=. \
	$(NULL)

bitlyfier_LDADD = \
	$(BITLYFIER_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)
