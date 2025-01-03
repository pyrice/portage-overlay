# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils flag-o-matic git-r3 linux-info multilib

DESCRIPTION="A daemon to run x86 code in an emulated environment"
#HOMEPAGE="https://dev.gentoo.org/~spock/projects/uvesafb/"
#SRC_URI="https://dev.gentoo.org/~spock/projects/uvesafb/archive/${P/_/-}.tar.bz2"
HOMEPAGE="https://github.com/sarnold/v86d/"
EGIT_REPO_URI="https://github.com/sarnold/v86d.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug x86emu"

DEPEND="dev-libs/klibc
	dev-libs/libx86"
RDEPEND=""

S="${WORKDIR}/${P//_*/}"

pkg_setup() {
	linux-info_pkg_setup
}

src_prepare() {
	if [ -z "$(grep V86D ${EROOT}/usr/include/linux/connector.h)" ]; then
		eerror "You need to compile klibc against a kernel tree patched with uvesafb"
		eerror "prior to merging this package."
		die "Kernel not patched with uvesafb."
	fi
	default
}

src_configure() {
	./configure --with-klibc $(use_with debug) $(use_with x86emu) || die
}

src_compile() {
	# Disable stack protector, as it does not work with klibc (bug #346397).
	filter-flags -fstack-protector -fstack-protector-all
	#append-cflags "-nostdinc -I/usr/include -I/usr/local/include"
	emake KDIR="${EROOT}"/usr || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc README ChangeLog

	insinto /usr/share/${PN}
	doins misc/initramfs
}

pkg_postinst() {
	elog "If you wish to place v86d into an initramfs image, you might want to use"
	elog "'/usr/share/${PN}/initramfs' in your kernel's CONFIG_INITRAMFS_SOURCE."
}

