bin_PROGRAMS = qetesh 

AM_CPPFLAGS = \
    -DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
    -DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
    -DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
    $(QETESH_CPPFLAGS)

AM_CFLAGS =\
     -Wall\
     -g \
	 `mysql_config --cflags --libs` \
	 $(QETESH_CFLAGS)


qetesh_SOURCES =  \
	Server.vala RequestRouter.vala  

AM_VALAFLAGS =  -g --pkg libqetesh --pkg gee-0.8 --pkg gio-unix-2.0 --pkg gio-2.0 --pkg glib-2.0 --pkg gobject-2.0 --pkg gmodule-2.0 --pkg posix  --target-glib=2.38

qetesh_LDFLAGS = \
    -Wl,--export-dynamic

qetesh_LDADD = $(QETESH_LIBS)

dist_sysconf_DATA = qetesh.conf

confdir = $(sysconfdir)/qetesh.conf.d

dist_conf_DATA = qetesh.conf.d/qetesh-internal.conf
