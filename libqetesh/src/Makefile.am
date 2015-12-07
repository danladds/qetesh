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
	libqetesh.vala Data/DataErrors.vala Data/QDateTime.vala Data/Validators.vala Data/DataObject.vala Data/QDatabase.vala Data/QMysqlDB.vala Data/QDatabaseConn.vala Data/QMysqlConn.vala 	Data/DataManager.vala Data/QDataQuery.vala Data/QMysqlQuery.vala Data/DataNode.vala	HTTPResponse.vala JSONResponse.vala HTTPRequest.vala QWebApp.vala AppModule.vala ModuleManager.vala QWebNode.vala QManifest.vala 	Data/DBManager.vala WebServerContext.vala WebAppContext.vala 	RequestDataParser.vala JSONRequestDataParser.vala ErrorManager.vala 	ConfigFile.vala ConfigFileParser.vala FileParser.vala Errors.vala 

libqetesh_la_VALAFLAGS = -g --pkg gio-unix-2.0 --pkg gio-2.0 --pkg gee-0.8  --pkg glib-2.0 --pkg gobject-2.0 --pkg gmodule-2.0 --pkg mysql --target-glib=2.38 --vapi=libqetesh.vapi -H libqetesh.h --library=libqetesh 

libqetesh_la_LDFLAGS = \
    -Wl,--export-dynamic

libqetesh_la_LIBADD = $(LIBQETESH_LIBS)


pkginclude_HEADERS = libqetesh.vapi libqetesh.h

