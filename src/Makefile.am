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

launcherdir = ${datadir}/applications
launcher_DATA = bitlyfier.desktop

edit = sed -e 's,@BINDIR\@,$(bindir),g' -e 's,@PIXMAPDIR\@,$(pixmapdir),g'

bitlyfier.desktop: Makefile bitlyfier.desktop.in
	rm -f bitlyfier.desktop bitlyfier.desktop.tmp
	$(edit) bitlyfier.desktop.in > bitlyfier.desktop.tmp
	mv bitlyfier.desktop.tmp bitlyfier.desktop

bitlyfierextradir = ${datadir}/bitlyfier/ui
bitlyfierextra_DATA =                                                    \
	ui/windows.ui                                                          \
	$(NULL)

bitlyfierpixmapsdir = ${datadir}/pixmaps
bitlyfierpixmaps_DATA =                                                  \
	ui/bitlyfier.png                                                       \
	$(NULL)

bitlyfierextrapixmapsdir = ${datadir}/bitlyfier/ui
bitlyfierextrapixmaps_DATA =                                             \
	ui/bitlyfier-about.png                                                 \
	ui/bitlyfier-small.png                                                 \
	$(NULL)

EXTRA_DIST =                                                             \
	$(bitlyfierextra_DATA)                                                 \
	$(bitlyfierpixmaps_DATA)                                               \
	$(bitlyfierextrapixmaps_DATA)                                          \
	$(NULL)

DISTCLEANFILES =                                                         \
	$(NULL)

