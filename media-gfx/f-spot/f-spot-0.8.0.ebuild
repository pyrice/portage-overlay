# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/f-spot/f-spot-0.8.0.ebuild,v 1.1 2010/10/01 19:40:19 pacho Exp $

EAPI="2"

inherit gnome2 mono eutils autotools multilib

DESCRIPTION="Personal photo management application for the gnome desktop"
HOMEPAGE="http://f-spot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc flickr raw"

RDEPEND=">=dev-lang/mono-2.2
	>=gnome-base/libgnome-2.2
	>=gnome-base/libgnomeui-2.2
	dev-dotnet/gnome-keyring-sharp
	>=dev-dotnet/gtk-sharp-2.12.2
	>=dev-dotnet/glib-sharp-2.12.2
	>=x11-libs/gtk+-2.16
	>=dev-libs/glib-2.22
	>=dev-libs/libunique-1.0
	>=dev-dotnet/gnome-sharp-2.8
	>=dev-dotnet/glib-sharp-2.12
	>=dev-dotnet/gconf-sharp-2.20.2
	>=dev-dotnet/mono-addins-0.3
	>=dev-libs/dbus-glib-0.71
	>=dev-dotnet/dbus-sharp-0.4.2
	>=dev-dotnet/dbus-glib-sharp-0.3.0
	>=media-libs/lcms-1.12:0
	>=x11-libs/cairo-1.4
	doc? (	virtual/monodoc
		>=app-text/gnome-doc-utils-0.17.3 )
	flickr? ( >=dev-dotnet/flickrnet-bin-2.2-r1 )
	raw?	( media-gfx/dcraw )"

DEPEND="${RDEPEND}
	>=dev-dotnet/gtk-sharp-gapi-2.12.2
	>=app-text/gnome-doc-utils-0.17.3
	dev-util/pkgconfig
	>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-static
		--disable-scrollkeeper
		$(use_enable doc user-help)"
}

src_prepare() {
	gnome2_src_prepare

	# Don't crash with empty databases
	epatch "${FILESDIR}/${P}-empty-crash.patch"

	sed  -r -i -e 's:-D[A-Z]+_DISABLE_DEPRECATED::g' \
		lib/libfspot/Makefile.am || die

	if ! use flickr; then
		sed -i -e '/FSpot.Exporters.Flickr/d' src/Extensions/Exporters/Makefile.am || die
		sed -i -e '/FSPOT_CHECK_FLICKRNET/d' configure.ac || die
	fi

	# update for mono-2.8.0
	epatch "${FILESDIR}/${P}-csharp.patch"

	intltoolize --force --automake --copy || die "intltoolized failed"
	AT_M4DIR="build/m4/f-spot build/m4/shamrock build/m4/shave" eautoreconf
}

src_install() {
	gnome2_src_install
	find "${D}" -name '*.la' -delete || die "la removal failed"
}
