# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/inkscape/inkscape-0.48.0.ebuild,v 1.10 2011/01/04 09:15:25 xmw Exp $

EAPI=2
inherit eutils flag-o-matic autotools gnome2

MY_P="${P/_/}"
S="${WORKDIR}/${MY_P}"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 hppa ppc ~ppc64 sparc x86"
IUSE="dia gnome gs inkjar lcms nls spell wmf"

RESTRICT="test"

COMMON_DEPEND="
	>=app-text/poppler-0.12.3-r3[cairo,xpdf-headers]
	dev-cpp/glibmm
	>=dev-cpp/gtkmm-2.18.0
	>=dev-libs/boehm-gc-6.4
	>=dev-libs/glib-2.6.5
	>=dev-libs/libsigc++-2.0.12
	>=dev-libs/libxml2-2.6.20
	>=dev-libs/libxslt-1.0.15
	dev-libs/popt
	dev-python/lxml
	media-gfx/imagemagick
	media-libs/fontconfig
	>=media-libs/freetype-2
	>=media-libs/libpng-1.2
	>=media-libs/libwpg-0.1
	sci-libs/gsl
	x11-libs/libXft
	>=x11-libs/gtk+-2.10.7
	>=x11-libs/pango-1.4.0
	|| ( dev-lang/python[xml] dev-python/pyxml )
	gnome? ( >=gnome-base/gnome-vfs-2.0 )
	lcms? ( =media-libs/lcms-1* )
	spell? (
		app-text/aspell
		app-text/gtkspell
	)"

# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="
	${COMMON_DEPEND}
	dev-python/numpy
	dia? ( app-office/dia )
	gs? ( app-text/ghostscript-gpl )
	wmf? ( media-libs/libwmf )"

DEPEND="${COMMON_DEPEND}
	dev-libs/boost
	sys-devel/gettext
	dev-util/pkgconfig
	x11-libs/libX11
	>=dev-util/intltool-0.29"

pkg_setup() {
	G2CONF="${G2CONF} --without-perl"
	G2CONF="${G2CONF} --enable-poppler-cairo"
	G2CONF="${G2CONF} --with-xft"
	G2CONF="${G2CONF} $(use_with gnome gnome-vfs)"
	G2CONF="${G2CONF} $(use_with inkjar)"
	G2CONF="${G2CONF} $(use_enable lcms)"
	G2CONF="${G2CONF} $(use_enable nls)"
	G2CONF="${G2CONF} $(use_with spell aspell)"
	G2CONF="${G2CONF} $(use_with spell gtkspell)"
	DOCS="AUTHORS ChangeLog NEWS README*"
}

src_prepare() {
	gnome2_src_prepare
	epatch "${FILESDIR}"/${P}-spell.patch

	# Upstream commit:
	# http://bazaar.launchpad.net/~inkscape.dev/inkscape/RELEASE_0_48_BRANCH/revision/9727
	epatch "${FILESDIR}"/${P}-poppler-0.16.patch
	epatch "${FILESDIR}"/${P}-missing-icon.patch
	epatch "${FILESDIR}"/${P}-gtk_fix.diff
	eautoreconf
}

src_configure() {
	# aliasing unsafe wrt #310393
	append-flags -fno-strict-aliasing
	gnome2_src_configure
}

pkg_postinst() {
	elog "local configurations (also includes extensions) are moved from"
	elog "\${HOME}/.inkscape to \${HOME}/.config/inkscape within"
	elog ">=media-gfx/inkscape-0.47"
}
