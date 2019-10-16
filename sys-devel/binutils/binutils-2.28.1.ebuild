# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd -sparc-fbsd ~x86-fbsd"

src_prepare() {
	toolchain-binutils_src_prepare

	# trying fix without changing paths first
#	is_cross && epatch "${FILESDIR}"/${PN}-remove-toolsdir.patch
}