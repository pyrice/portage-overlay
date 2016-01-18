# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=3
inherit eutils autotools flag-o-matic elisp-common

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="https://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"

LICENSE="LGPL-3"
KEYWORDS="~amd64 ~arm"
IUSE="networking +regex +deprecated emacs nls debug-freelist debug-malloc debug +threads"

RDEPEND="
	dev-libs/gmp
	>=sys-devel/libtool-1.5.6
	sys-devel/gettext
	virtual/pkgconfig
	dev-libs/libunistring
	>=dev-libs/boehm-gc-7.0[threads?]
	virtual/libffi
	sys-libs/ncurses
	emacs? ( virtual/emacs )"
DEPEND="${RDEPEND}
	sys-apps/texinfo"

SLOT="2"
MAJOR="2.0"
MY_SUFFIX="${SLOT}" # current soname is libguile-2.0.so.22

src_prepare() {

	epatch_user

	eautoreconf
}

src_configure() {
	# see bug #178499
	filter-flags -ftree-vectorize -flto*

	#will fail for me if posix is disabled or without modules -- hkBst
	econf \
		--disable-error-on-warning \
		--disable-static \
		--enable-posix \
		--program-suffix="${MY_SUFFIX}" \
		$(use_enable networking) \
		$(use_enable regex) \
		$(use_enable deprecated) \
		$(use_enable nls) \
		--disable-rpath \
		$(use_enable debug-freelist) \
		$(use_enable debug-malloc) \
		$(use_enable debug guile-debug) \
		$(use_with threads) \
		--with-modules # \
#		EMACS=no
}

src_compile()  {
	emake || die "make failed"

	# Above we have disabled the build system's Emacs support;
	# for USE=emacs we compile (and install) the files manually
	# if use emacs; then
	# 	cd emacs
	# 	make
	# 	elisp-compile *.el || die
	# fi
}

src_install() {
	einstall || die "install failed"

	dodoc AUTHORS ChangeLog GUILE-VERSION HACKING NEWS README THANKS || die

	# texmacs needs this, closing bug #23493
	dodir /etc/env.d
	echo "GUILE_LOAD_PATH=\"${EPREFIX}/usr/share/guile/${MAJOR}\"" > "${ED}"/etc/env.d/50guile-"${MY_SUFFIX}"

	# necessary for registering slib, see bug 206896
	keepdir /usr/share/guile-"${MY_SUFFIX}"/site

	mk_infoslot

	# if use emacs; then
	# 	elisp-install ${PN} emacs/*.{el,elc} || die
	# 	elisp-site-file-install "${FILESDIR}/50${PN}-gentoo.el" || die
	# fi

	# until slotting is official, things will look for guile-config
	if ! has_version dev-scheme/guile:12 ; then
		ln -sfn /usr/bin/guile-config2 "${ED}/usr/bin/guile-config"
	fi

	# This should not be installed as a library should it?
	use debug || rm -f "${ED}"/usr/lib/libguile-2.0.so.22.7.2-gdb.scm
}

mk_infoslot() {
	local f
	for f in "${ED}"/usr/share/info/guile.info* ; do
		mv ${f} ${f/guile.info/guile-"${MY_SUFFIX}".info} || die "mv ${f} failed"
	done
	mv "${ED}"/usr/share/info/r5rs.info "${ED}"/usr/share/info/r5rs-"${MY_SUFFIX}".info
	mv "${ED}"/usr/share/aclocal/guile.m4 "${ED}"/usr/share/aclocal/guile-"${MY_SUFFIX}".m4
}

pkg_postinst() {
	[ "${EROOT}" == "/" ] && pkg_config
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}

pkg_config() {
	if has_version dev-scheme/slib; then
		einfo "Registering slib with guile"
		install_slib_for_guile
	fi
}

_pkg_prerm() {
	rm -f "${EROOT}"/usr/share/guile-"${MY_SUFFIX}"/site/slibcat
}
