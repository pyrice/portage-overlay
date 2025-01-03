# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils flag-o-matic

DESCRIPTION="Mediastreaming library for telephony application"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="https://github.com/BelledonneCommunications/mediastreamer2/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0/3"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
# Many cameras will not work or will crash an application if mediastreamer2 is
# not built with v4l2 support (taken from configure.ac)
# TODO: run-time test for ipv6: does it really need ortp[ipv6] ?
IUSE="+alsa amr bindist coreaudio debug doc examples +filters g726 g729 gsm ilbc
	ipv6 libav ntp-timestamp opengl opus +ortp oss pcap portaudio pulseaudio sdl
	silk +speex static-libs test theora upnp v4l video x264 X"

REQUIRED_USE="|| ( oss alsa portaudio coreaudio pulseaudio )
	video? ( || ( opengl sdl X ) )
	theora? ( video )
	X? ( video )
	v4l? ( video )
	opengl? ( video )"

RDEPEND="alsa? ( media-libs/alsa-lib )
	g726? ( >=media-libs/spandsp-0.0.6_pre1 )
	gsm? ( media-sound/gsm )
	opus? ( media-libs/opus )
	ortp? ( >=net-libs/ortp-0.27.0 )
	pcap? ( sys-libs/libcap )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.21 )
	speex? ( >=media-libs/speex-1.2[utils] )
	upnp? ( net-libs/libupnp )
	video? (
		libav? ( <media-video/libav-12:0= )
		!libav? ( >=media-video/ffmpeg-1.2.6-r1:0= )

		opengl? ( media-libs/glew
			virtual/opengl
			x11-libs/libX11 )
		v4l? ( media-libs/libv4l
			sys-kernel/linux-headers )
		theora? ( media-libs/libtheora )
		sdl? ( media-libs/libsdl[video,X] )
		X? ( x11-libs/libX11
			x11-libs/libXext
			x11-libs/libXv ) )"
DEPEND="${RDEPEND}
	app-misc/bctoolbox
	dev-util/intltool
	virtual/pkgconfig
	app-editors/vim-core
	doc? ( app-doc/doxygen )
	opengl? ( dev-util/xxdi )
	test? ( >=dev-util/cunit-2.1_p2[ncurses] )
	X? ( x11-proto/videoproto
		x11-proto/xextproto )"

PDEPEND="amr? ( !bindist? ( media-plugins/mediastreamer-amr ) )
	g729? ( !bindist? ( media-plugins/mediastreamer-bcg729 ) )
	ilbc? ( media-plugins/mediastreamer-ilbc )
	video? ( x264? ( media-plugins/mediastreamer-x264 ) )
	silk? ( !bindist? ( media-plugins/mediastreamer-silk ) )"

S="${WORKDIR}/${PN}2-${PV}"

src_prepare() {
	# variable causes "command not found" warning and is not
	# needed anyway
	sed -i \
		-e 's/$(ACLOCAL_MACOS_FLAGS)//' \
		Makefile.am || die

	# respect user's CFLAGS
	sed -i \
		-e "s:-O2::;s: -g::" \
		configure.ac || die "patching configure.ac failed"

	# change default paths
	sed -i \
		-e "s:\(prefix/share\):\1/${PN}:" \
		configure.ac || die "patching configure.ac failed"

	# fix doc installation dir
	sed -i \
		-e "s:\$(pkgdocdir):\$(docdir):" \
		help/Makefile.am || die "patching help/Makefile.am failed"

	# fix html installation dir
	sed -i \
		-e "s:\(doc_htmldir=\).*:\1\$(htmldir):" \
		help/Makefile.am || die "patching help/Makefile.am failed"

	# linux/videodev.h dropped in 2.6.38
	sed -i \
		-e 's:linux/videodev.h ::' \
		configure.ac || die

	epatch "${FILESDIR}/${PN}-2.9.0-tests.patch"

	eautoreconf
}

src_configure() {
	replace-flags "-O3" "-O2"
	append-cflags "-Dbctbx_list_remove_link=bctbx_list_unlink -Dbctbx_list_delete_link=bctbx_list_erase_link"
	append-libs Xext

	local myeconfargs=(
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html
		--datadir="${EPREFIX}"/usr/share/${PN}
		# arts is deprecated
		--disable-artsc
		# don't want -Werror
		--disable-strict
		--disable-libv4l1
		# don't use bundled libs
		--enable-external-ortp
		$(use_enable alsa)
		$(use_enable pulseaudio)
		$(use_enable coreaudio macsnd)
		$(use_enable debug)
		$(use_enable filters)
		$(use_enable g726 spandsp)
		$(use_enable gsm)
		$(use_enable ipv6)
		$(use_enable ntp-timestamp)
		$(use_enable opengl glx)
		$(use_enable opus)
		$(use_enable ortp)
		$(use_enable oss)
		$(use_enable pcap)
		$(use_enable portaudio)
		$(use_enable speex)
		$(use_enable static-libs static)
		$(use_enable theora)
		$(use_enable upnp)
		$(use_enable video)
		$(use_enable v4l)
		$(use_enable v4l libv4l2)
		$(use_enable sdl)
		$(use_enable X x11)
		$(use_enable X xv)

		$(use doc || echo ac_cv_path_DOXYGEN=false)
	)

	# Mac OS X Audio Queue is an audio recording facility, available on
	# 10.5 (Leopard, Darwin9) and onward
	if use coreaudio && [[ ${CHOST} == *-darwin* && ${CHOST##*-darwin} -ge 9 ]]
	then
		myeconfargs+=( --enable-macaqsnd )
	else
		myeconfargs+=( --disable-macaqsnd )
	fi

	econf "${myeconfargs[@]}"
}

src_test() {
	default
	cd tester || die
	./mediastreamer2_tester || die
}

src_install() {
	default
	prune_libtool_files

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins tester/*.c
	fi
}
