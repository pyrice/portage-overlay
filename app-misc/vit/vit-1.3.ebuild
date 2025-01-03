# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Perl/Curses front-end for Taskwarrior (app-misc/task)"
HOMEPAGE="https://github.com/scottkosty/vit"
SRC_URI="https://github.com/scottkosty/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

DEPEND="
	app-misc/task
	dev-lang/perl
	dev-perl/Curses"
RDEPEND="${DEPEND}"

RESTRICT="test" # missing the extra .makefile for extra targets (like test)
