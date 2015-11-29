pkglib_LTLIBRARIES = libqetesh.la

libqetesh_la_CPPFLAGS = \
    -DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
    -DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
    -DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
    $(LIBQETESH_CPPFLAGS)

libqetesh_la_CFLAGS =\
     -Wall\
     -g \
	 $(LIBQETESH_CFLAGS)


libqetesh_la_SOURCES =  \
	libqetesh.vala HTTPResponse.vala EventManager.vala JSONResponse.vala FileParser.vala ErrorManager.vala AppModule.vala ModuleManager.vala ConfigFile.vala ConfigFileParser.vala QException.vala QEvent.vala HTTPRequest.vala DataObject.vala DBManager.vala QDatabase.vala QMysqlDB.vala QDatabaseConn.vala QMysqlConn.vala DataManager.vala WebServerContext.vala WebAppContext.vala QWebApp.vala HTMLElement.vala QWebNode.vala QManifest.vala QDateTime.vala RequestDataParser.vala JSONRequestDataParser.vala

libqetesh_la_VALAFLAGS = -g --pkg gio-unix-2.0 --pkg gio-2.0 --pkg gee-0.8  --pkg glib-2.0 --pkg gobject-2.0 --pkg gmodule-2.0 --pkg mysql --target-glib=2.38 --vapi=libqetesh.vapi -H libqetesh.h --library=libqetesh 

libqetesh_la_LDFLAGS = \
    -Wl,--export-dynamic

libqetesh_la_LIBADD = $(LIBQETESH_LIBS)


pkginclude_HEADERS = libqetesh.vapi libqetesh.h

