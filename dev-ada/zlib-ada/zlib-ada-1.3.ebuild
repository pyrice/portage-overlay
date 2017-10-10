# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

DESCRIPTION="ZLib.Ada is a thick binding to the popular compression/decompression library ZLib."
HOMEPAGE="http://zlib-ada.sourceforge.net"
SRC_URI="mirror://sourceforge/zlib-ada/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	virtual/ada"

src_compile(){
	gnatmake -P zlib
}