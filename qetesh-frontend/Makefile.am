ACLOCAL_AMFLAGS = -I m4
SUBDIRS = src
EXTRA_DIST = autogen.sh

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = qetesh-frontend.pc

dist_doc_DATA = \
    README \
    COPYING \
    AUTHORS \
    ChangeLog \
    INSTALL \
	NEWS


# Remove doc directory on uninstall
uninstall-local: -rm -r $(docdir)
