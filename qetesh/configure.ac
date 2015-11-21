AC_INIT(qetesh, 0.3, dan@danladds.com)

dnl Keep the project dir clean
AC_CONFIG_AUX_DIR(config)
AC_CONFIG_SRCDIR(src)

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([qetesh.pc])

AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])
AC_PROG_CC
AM_PROG_LIBTOOL

LT_INIT

dnl Check for vala
AM_PROG_VALAC([0.10.0])

PKG_CHECK_MODULES(QETESH, [ gio-2.0 glib-2.0 gobject-2.0 gee-0.8 gmodule-2.0 libqetesh ])

AC_SUBST(QETESH_CFLAGS)
AC_SUBST(QETESH_LIBS)

AC_OUTPUT([
Makefile
src/Makefile

])
