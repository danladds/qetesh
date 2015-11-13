AC_INIT(libqetesh, 0.2, dan@el-topo.co.uk)

dnl Keep the project dir clean
AC_CONFIG_AUX_DIR(config)
AC_CONFIG_SRCDIR(src)

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([libqetesh.pc])

AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])
AC_PROG_CC
AM_PROG_LIBTOOL

LT_INIT

dnl Check for vala
AM_PROG_VALAC([0.10.0])

PKG_CHECK_MODULES(LIBQETESH, [gio-2.0 glib-2.0 >= 2.38.1 gobject-2.0 gee-0.8 ])

AC_SUBST(LIBQETESH_CFLAGS)
AC_SUBST(LIBQETESH_LIBS)

AC_OUTPUT([
Makefile
src/Makefile
])
