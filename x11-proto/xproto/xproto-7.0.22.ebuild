# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

XORG_DOC=doc
inherit xorg-2

DESCRIPTION="X.Org xproto protocol headers"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc pdf"

PDEPEND="doc? ( x11-misc/xorg-sgml-doctools )"
RDEPEND=""
DEPEND="${RDEPEND}
	doc? ( app-text/xmlto
		( pdf? ( dev-java/fop ) )
		)"

pkg_setup() {
	xorg-2_pkg_setup

	use doc && my_conf="$(use_with pdf fop)"
	if use pdf && ! use doc ; then
		elog "You need to enable doc for the pdf flag to mean something..."
	fi

	XORG_CONFIGURE_OPTIONS=(
		$(use_enable doc specs)
		$(use_with doc xmlto)
		$my_conf
	)
}
