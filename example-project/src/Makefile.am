lib_LTLIBRARIES = libqeteshexample.la

AM_CPPFLAGS = \
    -DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
    -DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
    -DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
    $(QETESH_EXAMPLE_CPPFLAGS)

AM_CFLAGS =\
     -Wall\
     -g \
     -fPIC\
     $(QETESH_EXAMPLE_CFLAGS)


libqeteshexample_la_SOURCES =  \
    QExample.vala \
    data/Invoice.vala \
    data/InvoiceItem.vala \
    api/InvoiceNode.vala

libqeteshexample_la_VALAFLAGS = --pkg gio-unix-2.0 --pkg gio-2.0 --pkg glib-2.0 --pkg gobject-2.0 --pkg gee-0.8 --pkg libqetesh --target-glib=2.38 --library=libqeteshexample

libqeteshexample_la_LDFLAGS = \
    -Wl -avoid-version -module -shared  --export-dynamic

libqeteshexample_la_LIBADD = $(QETESH_EXAMPLE_LIBS)

jsdir = $(pkgdatadir)/js
cssdir = $(pkgdatadir)/css
tpldir = $(pkgdatadir)/tpl
htmldir = $(pkgdatadir)
qconfdir = $(sysconfdir)/qetesh.conf.d

dist_html_DATA = \
	frontend/index.html

dist_js_DATA = \
	frontend/js/example.js

dist_css_DATA = \
	frontend/css/example.css
	
dist_tpl_DATA = \
	frontend/tpl/list.html \
	frontend/tpl/record.html

dist_qconf_DATA = \
	qexample.conf
