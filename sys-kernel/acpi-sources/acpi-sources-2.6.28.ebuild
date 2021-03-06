# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

UNIPATCH_STRICTORDER="yes"
K_SECURITY_UNSUPPORTED="1"

ETYPE="sources"
inherit kernel-2
detect_version

# set to either test or release; check URI below if working with an rc kernel
BRANCH="release"
# release date gets removed once kernels go from _rc to released
RELEASE_DATE=""

APV=${RELEASE_DATE}-${OKV}
APV_URI="http://ftp.kernel.org/pub/linux/kernel/people/lenb/acpi/patches/${BRANCH}/${OKV}/acpi-${BRANCH}-${APV}.diff.bz2"
UNIPATCH_LIST="${DISTDIR}/acpi-${BRANCH}-${APV}.diff.bz2"

DESCRIPTION="ACPI-patched sources (${BRANCH} branch) for the vanilla ${KV_MAJOR}.${KV_MINOR} kernel tree"
HOMEPAGE="http://www.lesswatts.org/projects/acpi/"

SRC_URI="${KERNEL_URI} ${APV_URI} ${ARCH_URI}"
KEYWORDS="~amd64 ~x86"

EPATCH_OPTS="-Np1"
K_EXTRAEINFO="This kernel is not officially supported by Gentoo, however, it
should be fairly stable since it's the vanilla kernel source with the latest
ACPI release for that kernel version (the vanilla kernel is a little behind).
If you have a modern laptop or desktop and are having trouble with system
initialization, power management, or setting the CPU frequency, then these
patches may help.  You should also make sure you have the latest BIOS update
from your motherboard or system vendor."
