# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils

DESCRIPTION="Tools for manipulating UEFI secure boot platforms"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/jejb/efitools.git"
SRC_URI="https://git.kernel.org/pub/scm/linux/kernel/git/jejb/efitools.git/snapshot/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="libressl"

RDEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	sys-apps/util-linux"
DEPEND="${RDEPEND}
	sys-apps/help2man
	>=sys-boot/gnu-efi-3.0u
	app-crypt/sbsigntool
	virtual/pkgconfig
	dev-perl/File-Slurp"

S=${WORKDIR}/v${PV}

src_prepare() {
	epatch "${FILESDIR}"/${PV}-Make.rules.patch \
		"${FILESDIR}"/${PV}-add-sys-types-for-u_char.patch
	epatch_user
}
