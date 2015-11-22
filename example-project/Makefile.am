ACLOCAL_AMFLAGS = -I m4
SUBDIRS = src

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = qetesh-example.pc

dist_doc_DATA = \
    README \
    COPYING \
    AUTHORS \
    ChangeLog \
    INSTALL \
    NEWS


# Remove doc directory on uninstall
uninstall-local: -rm -r $(docdir)
