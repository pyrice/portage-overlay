# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils python-single-r1

MY_PN="Exaile-Soundmenu-Indicator"

DESCRIPTION="Sound menu indicator plugin (adds MPRISv2 support) for XFCE Panel and Gnome Shell"
HOMEPAGE="https://github.com/sarnold/Exaile-Soundmenu-Indicator"

if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="https://github.com/sarnold/Exaile-Soundmenu-Indicator.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="https://github.com/sarnold/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"
	S="${WORKDIR}/${MY_PN}-${PV}"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="gnome xfce"

RESTRICT="test"

PDEPEND=">=media-sound/exaile-3.0[${PYTHON_USEDEP}]"

RDEPEND="${PYTHON_DEPS}
	xfce? ( xfce-extra/xfce4-soundmenu-plugin )
	gnome? ( gnome-base/gnome-shell )"

DEPEND="${RDEPEND}"

REQUIRED_USE="|| ( xfce gnome ) ${PYTHON_REQUIRED_USE}"

RESTRICT="test"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_install() {
	insinto /usr/share/exaile/plugins/${PN}
	doins __init__.py  mpris2.py  PLUGININFO || die

	dodoc README.md
}

