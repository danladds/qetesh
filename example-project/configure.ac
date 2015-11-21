AC_INIT(qetesh-example, 0.1, dan@danladds.com)

dnl Keep project dir clean
AC_CONFIG_AUX_DIR(config)
AC_CONFIG_SRCDIR(src)

AC_CONFIG_HEADERS([config.h])

AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])
AC_PROG_CC

LT_INIT

dnl Check for vala
AM_PROG_VALAC([0.10.0])


PKG_CHECK_MODULES(QETESH_EXAMPLE, [zlib gio-2.0 glib-2.0 gobject-2.0 gee-0.8 libqetesh ])

AC_SUBST(QETESH_EXAMPLE_CFLAGS)
AC_SUBST(QETESH_EXAMPLE_LIBS)

AC_OUTPUT([
Makefile
src/Makefile
])
