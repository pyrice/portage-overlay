# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils flag-o-matic multilib multilib-minimal toolchain-funcs

if [[ ${PV} == *9999 ]] ; then
	: ${EGIT_REPO_URI:="git://git.libav.org/libav.git"}
	if [[ ${PV%9999} != "" ]] ; then
		: ${EGIT_BRANCH:="release/${PV%.9999}"}
	fi
	inherit git-r3
fi

DESCRIPTION="Complete solution to record, convert and stream audio and video"
HOMEPAGE="https://libav.org/"
if [[ ${PV} == *9999 ]] ; then
	SRC_URI=""
elif [[ ${PV%_p*} != ${PV} ]] ; then # Gentoo snapshot
	SRC_URI="https://dev.gentoo.org/~lu_zero/libav/${P}.tar.xz"
	SRC_URI+=" test? ( https://dev.gentoo.org/~lu_zero/libav/fate-${PV}.tar.xz )"
else # Official release
	SRC_URI="https://libav.org/releases/${P}.tar.xz"
	FATE_VER=${PV%%_*}
#	SRC_URI+=" test? ( https://dev.gentoo.org/~lu_zero/libav/fate-12-r1.tar.xz )"
fi

#SRC_URI+=" https://dev.gentoo.org/~lu_zero/libav/0001-xcb-Add-all-the-libraries-to-the-link-line-explicitl.patch"
# 9999 does not have fate-*.tar.xz

LICENSE="LGPL-2.1  gpl? ( GPL-3 )"
SLOT="0/12"
[[ ${PV} == *9999 ]] || KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64
~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos
~x64-solaris ~x86-solaris"
IUSE="aac alsa amr bs2b +bzip2 cdio cpudetection custom-cflags debug doc +encode faac fdk
	frei0r fontconfig +gpl gsm +hardcoded-tables ieee1394 jack jpeg2k libressl mp3
	+network nvidia openssl opus oss pic pulseaudio rtmp schroedinger sdl speex ssl
	static-libs test theora threads tools truetype twolame v4l vaapi vdpau vorbis vpx X
	wavpack webp x264 x265 xvid +zlib"

# String for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
CPU_FEATURES="altivec armv5te armv6 armv6t2 armvfp:vfp neon"
X86_CPU_FEATURES="3dnow:amd3dnow 3dnowext:amd3dnowext mmx mmxext sse sse2 sse3 ssse3 sse4_1:sse4 sse4_2:sse42 avx xop fma3 fma4 avx2"
for i in ${X86_CPU_FEATURES} ; do
	CPU_FEATURES+=" cpu_flags_x86_${i%:*}:${i#*:}"
done
for i in ${CPU_FEATURES} ; do
	IUSE+=" ${i%:*}"
done

RDEPEND="
	!media-video/ffmpeg:0
	alsa? ( >=media-libs/alsa-lib-1.0.27.2[${MULTILIB_USEDEP}] )
	amr? ( >=media-libs/opencore-amr-0.1.3-r1[${MULTILIB_USEDEP}] )
	bs2b? ( >=media-libs/libbs2b-3.1.0-r1[${MULTILIB_USEDEP}] )
	bzip2? ( >=app-arch/bzip2-1.0.6-r4[${MULTILIB_USEDEP}] )
	cdio? ( >=dev-libs/libcdio-paranoia-0.90_p1-r1[${MULTILIB_USEDEP}] )
	encode? (
		aac? ( >=media-libs/vo-aacenc-0.1.3[${MULTILIB_USEDEP}] )
		amr? ( >=media-libs/vo-amrwbenc-0.1.2-r1[${MULTILIB_USEDEP}] )
		faac? ( >=media-libs/faac-1.28-r3[${MULTILIB_USEDEP}] )
		mp3? ( >=media-sound/lame-3.99.5-r1[${MULTILIB_USEDEP}] )
		theora? (
			>=media-libs/libtheora-1.1.1[encode,${MULTILIB_USEDEP}]
			>=media-libs/libogg-1.3.0[${MULTILIB_USEDEP}]
		)
		twolame? ( >=media-sound/twolame-0.3.13-r1[${MULTILIB_USEDEP}] )
		vorbis? (
			>=media-libs/libvorbis-1.3.3-r1[${MULTILIB_USEDEP}]
			>=media-libs/libogg-1.3.0[${MULTILIB_USEDEP}]
		)
		webp? ( >=media-libs/libwebp-0.3.0[${MULTILIB_USEDEP}] )
		wavpack? ( >=media-sound/wavpack-4.60.1-r1[${MULTILIB_USEDEP}] )
		x264? ( >=media-libs/x264-0.0.20130506:=[${MULTILIB_USEDEP}] )
		x265? ( >=media-libs/x265-1.2:=[${MULTILIB_USEDEP}] )
		xvid? ( >=media-libs/xvid-1.3.2-r1[${MULTILIB_USEDEP}] )
	)
	nvidia? ( media-video/nvidia-video-codec )
	fdk? ( >=media-libs/fdk-aac-0.1.2[${MULTILIB_USEDEP}] )
	frei0r? ( media-plugins/frei0r-plugins )
	gsm? ( >=media-sound/gsm-1.0.13-r1[${MULTILIB_USEDEP}] )
	ieee1394? (
		>=media-libs/libdc1394-2.2.1[${MULTILIB_USEDEP}]
		>=sys-libs/libraw1394-2.1.0-r1[${MULTILIB_USEDEP}]
	)
	jack? ( >=media-sound/jack-audio-connection-kit-0.121.3-r1[${MULTILIB_USEDEP}] )
	jpeg2k? ( >=media-libs/openjpeg-1.5.0:0[${MULTILIB_USEDEP}] )
	opus? ( >=media-libs/opus-1.0.2-r2[${MULTILIB_USEDEP}] )
	pulseaudio? ( >=media-sound/pulseaudio-2.1-r1[${MULTILIB_USEDEP}] )
	rtmp? ( >=media-video/rtmpdump-2.4_p20131018[${MULTILIB_USEDEP}] )
	ssl? (
		openssl? (
			!libressl? ( >=dev-libs/openssl-1.0.1h-r2:0[${MULTILIB_USEDEP}] )
			libressl? ( dev-libs/libressl[${MULTILIB_USEDEP}] )
		)
		!openssl? ( >=net-libs/gnutls-2.12.23-r6[${MULTILIB_USEDEP}] )
	)
	sdl? ( >=media-libs/libsdl-1.2.15-r4[sound,video,${MULTILIB_USEDEP}] )
	schroedinger? ( >=media-libs/schroedinger-1.0.11-r1[${MULTILIB_USEDEP}] )
	speex? ( >=media-libs/speex-1.2_rc1-r1[${MULTILIB_USEDEP}] )
	truetype? (	>=media-libs/freetype-2.5.0.1:2[${MULTILIB_USEDEP}] )
	fontconfig? ( >=media-libs/fontconfig-2.10[${MULTILIB_USEDEP}] )
	vaapi? ( >=x11-libs/libva-1.2.1-r1[${MULTILIB_USEDEP}] )
	vdpau? ( >=x11-libs/libvdpau-0.7[${MULTILIB_USEDEP}] )
	vpx? ( >=media-libs/libvpx-1.2.0_pre20130625[${MULTILIB_USEDEP}] )
	X? ( >=x11-libs/libxcb-1.9.1[${MULTILIB_USEDEP}] )
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )
"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	doc? ( app-text/texi2html )
	ieee1394? ( >=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}] )
	cpu_flags_x86_mmx? ( dev-lang/yasm )
	rtmp? ( >=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}] )
	schroedinger? ( >=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}] )
	ssl? ( >=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}] )
	test? ( sys-devel/bc )
	truetype? ( >=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}] )
	fontconfig? ( >=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}] )
	v4l? ( sys-kernel/linux-headers )
"

RDEPEND="${RDEPEND}
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-medialibs-20140508-r3
		!app-emulation/emul-linux-x86-medialibs[-abi_x86_32(-)] )"

# faac can't be binary distributed
# openssl support marked as nonfree
# faac and aac are concurent implementations
# amr and aac require at least lgpl3
# x264 requires gpl2
REQUIRED_USE="
	rtmp? ( network )
	amr? ( gpl ) aac? ( gpl ) x264? ( gpl ) cdio? ( gpl ) x265? ( gpl )
	test? ( encode zlib )
	fontconfig? ( truetype )
"
RESTRICT="!test? ( test ) faac? ( bindist ) fdk? ( bindist ) openssl? ( bindist ) nvidia? ( bindist )"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/libavutil/avconfig.h
)

src_unpack() {
	[[ ${PV} == *9999 ]] && git-r3_src_unpack
	# 9999 does not have fate-*.tar.xz
	[[ ${PV%9999} != "" ]] && default_src_unpack
}

src_prepare() {
	epatch_user

	epatch "${FILESDIR}"/0001-xcb-Add-all-the-libraries-to-the-link-line-explicitl.patch

	# if we have snapshot then we need to hardcode the version
	if [[ ${PV%_p*} != ${PV} ]]; then
		sed -i -e "s/UNKNOWN/DATE-${PV#*_pre}/" "${S}/version.sh" || die
	fi

	TOOLS=( aviocat graph2dot ismindex pktdumper qt-faststart trasher )
	use zlib && TOOLS+=( cws2fws )

	MAKEOPTS+=" V=1"
}

multilib_src_configure() {
	local myconf=( ${EXTRA_LIBAV_CONF} )
	local uses i

	# 9999 does not have fate-*.tar.xz
	[[ ${PV%9999} != "" ]] && use test && myconf+=( --samples="${WORKDIR}/fate" )

	myconf+=(
		$(use_enable gpl)
		$(use_enable gpl version3)
		--enable-avfilter
	)

	# enabled by default
	uses="debug doc network zlib"
	for i in ${uses}; do
		use ${i} || myconf+=( --disable-${i} )
	done
	use bzip2 || myconf+=( --disable-bzlib )
	use sdl || myconf+=( --disable-avplay )

	if use ssl; then
		use openssl && myconf+=( --enable-openssl --enable-nonfree ) \
			|| myconf+=( --enable-gnutls )
	fi

	use custom-cflags && myconf+=( --disable-optimizations )
	use cpudetection && myconf+=( --enable-runtime-cpudetect )

	use vdpau || myconf+=( --disable-vdpau )

	use vaapi && myconf+=( --enable-vaapi )

	NVIDIA_INCLUDES="-I/opt/nvidia-video-codec/include -I/opt/cuda/include"
	NVIDIA_LIBS="-L/opt/cuda/lib64"
	use nvidia && myconf+=( --enable-nonfree --enable-cuda --enable-libnpp
						    --extra-cflags="$NVIDIA_INCLUDES" --extra-ldflags="$NVIDIA_LIBS" )

	# Encoders
	if use encode; then
		use faac && myconf+=( --enable-nonfree )
		use mp3 && myconf+=( --enable-libmp3lame )
		use amr && myconf+=( --enable-libvo-amrwbenc )
		use aac && myconf+=( --enable-libvo-aacenc )
		use nvidia && myconf+=( --enable-nvenc )
		uses="faac theora twolame vorbis wavpack webp x264 x265 xvid"
		for i in ${uses}; do
			use ${i} && myconf+=( --enable-lib${i} )
		done
	else
		myconf+=( --disable-encoders )
	fi

	# libavdevice options
	use cdio && myconf+=( --enable-libcdio )
	use ieee1394 && myconf+=( --enable-libdc1394 )
	use pulseaudio && myconf+=( --enable-libpulse )

	# Indevs
	# v4l1 is gone since linux-headers-2.6.38
	myconf+=( --disable-indev=v4l )
	use v4l || myconf+=( --disable-indev=v4l2 )
	for i in alsa oss jack; do
		use ${i} || myconf+=( --disable-indev=${i} )
	done
	use X && myconf+=( --enable-libxcb )
	# Outdevs
	for i in alsa oss ; do
		use ${i} || myconf+=( --disable-outdev=${i} )
	done
	# libavfilter options
	use bs2b && myconf+=( --enable-libbs2b )
	multilib_is_native_abi && use frei0r && myconf+=( --enable-frei0r )
	use truetype && myconf+=( --enable-libfreetype )
	use fontconfig && myconf+=( --enable-libfontconfig )

	# Threads; we only support pthread for now
	use threads && myconf+=( --enable-pthreads )

	# Decoders
	use amr && myconf+=( --enable-libopencore-amrwb --enable-libopencore-amrnb )
	use fdk && myconf+=( --enable-nonfree --enable-libfdk-aac )
	uses="gsm opus rtmp schroedinger speex vpx"
	for i in ${uses}; do
		use ${i} && myconf+=( --enable-lib${i} )
	done
	use jpeg2k && myconf+=( --enable-libopenjpeg )

	# CPU features
	for i in ${CPU_FEATURES}; do
		use ${i%:*} || myconf+=( --disable-${i#*:} )
	done

	# pass the right -mfpu as extra
	use neon && use arm && append-cflags -mfpu=neon

	# disable mmx accelerated code if PIC is required
	# as the provided asm decidedly is not PIC for x86.
	if use pic && [[ ${ABI} == x86 ]]; then
		myconf+=( --disable-mmx --disable-mmxext )
	fi

	# Option to force building pic
	use pic && myconf+=( --enable-pic )

	# cross compile support
	if tc-is-cross-compiler ; then
		myconf+=( --enable-cross-compile --arch=$(tc-arch-kernel) --cross-prefix=${CHOST}- )
		case ${CHOST} in
			*freebsd*)
				myconf+=( --target-os=freebsd )
				;;
			mingw32*)
				myconf+=( --target-os=mingw32 )
				;;
			*linux*)
				myconf+=( --target-os=linux )
				;;
		esac
	fi

	# Misc stuff
	use hardcoded-tables && myconf+=( --enable-hardcoded-tables )

	# Forcing arm would make the compiler break left and right
	if [[ ${ABI} == arm ]]; then
		filter-flags -marm
	fi

	# needs some help linking with gold...
	use X && append-libs $($(tc-getPKG_CONFIG) --libs xcb-randr)

	# Specific workarounds for too-few-registers arch...
	if [[ ${ABI} == x86 ]]; then
		local CFLAGS=${CFLAGS} CXXFLAGS=${CXXFLAGS}
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if use debug; then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	set -- "${S}"/configure \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--shlibdir="${EPREFIX}"/usr/$(get_libdir) \
		--mandir="${EPREFIX}"/usr/share/man \
		--enable-shared \
		--cc="$(tc-getCC)" \
		--ar="$(tc-getAR)" \
		--optflags="${CFLAGS}" \
		--extra-cflags="${CFLAGS}" \
		$(use_enable static-libs static) \
		"${myconf[@]}"
	echo "${@}"
	"${@}" || die
}

multilib_src_compile() {
	emake

	if use tools; then
		tc-export CC

		emake ${TOOLS[@]/#/tools/}
	fi
}

multilib_src_install() {
	emake DESTDIR="${D}" install install-man
	use doc && dodoc doc/*.html

	if use tools; then
		dobin ${TOOLS[@]/#/tools/}
	fi
}

multilib_src_install_all() {
	dodoc Changelog README.md INSTALL
}

multilib_src_test() {
	local _libs="$(for i in lib*/;do echo -n "${BUILD_DIR}/${i%/}:";done)"
	einfo "LD_LIBRARY_PATH is set to \"${_libs}\""
	LD_LIBRARY_PATH="${_libs}" make -j1 fate V=1
}
