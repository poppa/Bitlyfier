NULL = 

AM_CPPFLAGS =                                                            \
	-DDATADIR=\""$(datadir)"\"                                             \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\"                             \
	-DLOCALEDIR=\""$(localedir)"\"                                         \
	$(BITLYFIER_CFLAGS)                                                    \
	-include $(CONFIG_HEADER)                                              \
	$(NULL)

bin_PROGRAMS = bitlyfier

bitlyfier_SOURCES =                                                      \
	application.vala                                                       \
	mainwindow.vala                                                        \
	bitly.vala                                                             \
	main.vala                                                              \
	$(NULL)

bitlyfier_VALAFLAGS =                                                    \
	--thread                                                               \
	--pkg=gtk+-2.0                                                         \
	--pkg=gdk-2.0                                                          \
	--pkg=gconf-2.0                                                        \
	--pkg=gmodule-2.0                                                      \
	--pkg=gee-1.0                                                          \
	--pkg=libsoup-2.4                                                      \
	--pkg=json-glib-1.0                                                    \
	--pkg=config                                                           \
	--vapidir=.                                                            \
	$(NULL)

bitlyfier_LDADD =                                                        \
	$(BITLYFIER_LIBS)                                                      \
	$(NULL)

bitlyfierextradir = ${datadir}/bitlyfier/ui
bitlyfierextra_DATA =                                                    \
	ui/windows.ui                                                          \
	$(NULL)

bitlyfierpixmapsdir = ${datadir}/bitlyfier/ui
bitlyfierpixmaps_DATA =                                                  \
	ui/bitlyfier.png                                                       \
	ui/bitlyfier-small.png                                                 \
	$(NULL)

EXTRA_DIST =                                                             \
	$(bitlyfierextra_DATA)                                                 \
	$(bitlyfierpixmaps_DATA)                                               \
	$(NULL)

DISTCLEANFILES =                                                         \
	$(NULL)

