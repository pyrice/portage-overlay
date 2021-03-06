# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/easytag/easytag-2.1.7-r1.ebuild,v 1.1 2012/03/02 21:56:56 radhermit Exp $

EAPI=4
inherit eutils fdo-mime

DESCRIPTION="GTK+ utility for editing MP2, MP3, MP4, FLAC, Ogg and other media tags"
HOMEPAGE="http://easytag.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="flac mp3 mp4 speex vorbis wavpack"

RDEPEND=">=x11-libs/gtk+-2.12:2
	mp3? ( >=media-libs/id3lib-3.8.3-r7
		media-libs/libid3tag )
	flac? ( media-libs/flac
		media-libs/libvorbis )
	mp4? ( ~media-libs/libmp4v2-1.9.1 )
	vorbis? ( media-libs/libvorbis )
	wavpack? ( media-sound/wavpack )
	speex? ( media-libs/speex
		media-libs/libvorbis )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

DOCS=( ChangeLog README THANKS TODO USERS-GUIDE )

src_prepare() {
	epatch "${FILESDIR}"/${P}-gold.patch \
		"${FILESDIR}"/${PN}-2.1.6-load-from-txt.patch
}

src_configure() {
	econf \
		$(use_enable mp3) \
		$(use_enable mp3 id3v23) \
		$(use_enable vorbis ogg) \
		$(use_enable flac) \
		$(use_enable mp4) \
		$(use_enable wavpack) \
		$(use_enable speex)
}

pkg_postinst() { fdo-mime_desktop_database_update; }
pkg_postrm() { fdo-mime_desktop_database_update; }
