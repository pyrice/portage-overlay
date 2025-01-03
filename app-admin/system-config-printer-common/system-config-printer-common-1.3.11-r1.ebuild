# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/system-config-printer-common/system-config-printer-common-1.3.11-r1.ebuild,v 1.1 2012/08/08 17:15:29 ssuominen Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 )
WANT_AUTOMAKE="1.11"

inherit autotools eutils python-r1 toolchain-funcs

MY_P=${PN%-common}-${PV}

DESCRIPTION="Common modules of Red Hat's printer administration tool"
HOMEPAGE="http://cyberelk.net/tim/software/system-config-printer/"
SRC_URI="http://cyberelk.net/tim/data/${PN/-common}/${PV%.*}/${MY_P}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
SLOT="0"
IUSE="doc policykit"

# Needs cups running, bug 284005
RESTRICT="test"

# system-config-printer split since 1.1.3
COMMON_DEPEND="
	>=dev-libs/glib-2
	dev-libs/libxml2[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	>=dev-python/pycups-1.9.60[${PYTHON_USEDEP}]
	dev-python/pycurl[${PYTHON_USEDEP}]
	>=dev-python/pygobject-2.21.5:2[${PYTHON_USEDEP}]
	net-print/cups[dbus]
	>=sys-fs/udev-164-r2
	virtual/libusb:0
	${PYTHON_DEPS}
"
DEPEND="${COMMON_DEPEND}
	dev-util/intltool
	virtual/pkgconfig
	doc? ( dev-python/epydoc[${PYTHON_USEDEP}] )
"
RDEPEND="${COMMON_DEPEND}
	!<app-admin/system-config-printer-gnome-${PV}
	policykit? ( >=sys-auth/polkit-0.104-r1 )
"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-1.3.9-split.patch
	eautoreconf
}

src_configure() {
	econf \
		--disable-nls \
		--with-udev-rules
}

src_compile() {
	emake
	use doc && emake html
}

src_install() {
	emake \
		DESTDIR="${D}" \
		udevhelperdir="$($(tc-getPKG_CONFIG) --variable=udevdir udev)" \
		udevrulesdir="$($(tc-getPKG_CONFIG) --variable=udevdir udev)/rules.d" \
		install

	dodoc AUTHORS ChangeLog README
	use doc && dohtml -r html/

	python_convert_shebangs -q -r $(python_get_version) "${ED}"
}

pkg_postinst() {
	python_mod_optimize cupshelpers
}

pkg_postrm() {
	python_mod_cleanup cupshelpers /usr/share/system-config-printer
}
