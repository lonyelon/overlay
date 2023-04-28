# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

CMAKE_MAKEFILE_GENERATOR="emake"

inherit cmake

DESCRIPTION="a cross-platform SDR software with the aim of being bloat free and simple to use"
HOMEPAGE="https://github.com/AlexandreRouma/SDRPlusPlus"

SLOT="0"
LICENSE="GPL-3"

IUSE="airspy airspyhf bladerf filesource hackrf limesdr sddc rtltcp +rtlsdr sdrplay soapysdr spyserver plutosdr \
	+audiosink +networksink portaudio newportaudio \
	falcon9 m17decoder meteordemod radio weathersat \
	discord +frecuencymanager recorder rigctlserver"

PATCHES=( "${FILESDIR}/fix-cmake-libdir-location-1.0.4.patch" )

DEPEND="
	sci-libs/fftw
	media-libs/glfw
	media-libs/glew
	sci-libs/volk

	airspy? ( net-wireless/airspy )
	airspyhf? ( net-wireless/airspyhf )
	bladerf? ( net-wireless/bladerf )
	hackrf? ( net-libs/libhackrf )
	limesdr? ( net-wireless/limesuite )
	rtlsdr? ( net-wireless/rtl-sdr )
	sdrplay? ( net-wireless/sdrplay )
	soapysdr? ( net-wireless/soapysdr )
	plutosdr? ( net-libs/libiio net-libs/libad9361-iio )

	audiosink? ( media-libs/rtaudio )
	newportaudio? ( media-libs/portaudio )

	falcon9? ( media-video/ffmpeg )

	portaudio? ( media-libs/portaudio )
	"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/AlexandreRouma/SDRPlusPlus.git"
	inherit git-r3
else
	SRC_URI="https://github.com/AlexandreRouma/SDRPlusPlus/archive/${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/SDRPlusPlus-${PV}"
	KEYWORDS="~amd64 ~x86"
fi

src_configure() {
	local mycmakeargs=(
		-DOPT_BUILD_AIRSPY_SOURCE=$(usex airspy)
		-DOPT_BUILD_AIRSPYHF_SOURCE=$(usex airspyhf)
		-DOPT_BUILD_BLADERF_SOURCE=$(usex bladerf)
		-DOPT_BUILD_FILE_SOURCE=$(usex filesource)
		-DOPT_BUILD_HACKRF_SOURCE=$(usex hackrf)
		-DOPT_BUILD_LIMESDR_SOURCE=$(usex limesdr)
		-DOPT_BUILD_SDDC_SOURCE=$(usex sddc)
		-DOPT_BUILD_RTL_SDR_SOURCE=$(usex rtlsdr)
		-DOPT_BUILD_RTL_TCP_SOURCE=$(usex rtltcp)
		-DOPT_BUILD_SDRPLAY_SOURCE=$(usex sdrplay)
		-DOPT_BUILD_SOAPY_SOURCE=$(usex soapysdr)
		-DOPT_BUILD_SPYSERVER_SOURCE=$(usex spyserver)
		-DOPT_BUILD_PLUTOSDR_SOURCE=$(usex plutosdr)

		-DOPT_BUILD_AUDIO_SINK=$(usex audiosink)
		-DOPT_BUILD_NETWORK_SINK=$(usex networksink)
		-DOPT_BUILD_PORTAUDIO_SINK=$(usex portaudio)
		-DOPT_BUILD_NEW_PORTAUDIO_SINK=$(usex newportaudio)

		-DOPT_BUILD_FALCON9_DECODER=$(usex falcon9)
		-DOPT_BUILD_M17_DECODER=$(usex m17decoder)
		-DOPT_BUILD_METEOR_DEMODULATOR=$(usex meteordemod)
		-DOPT_BUILD_RADIO=$(usex radio)
		-DOPT_BUILD_WEATHER_SAT_DECODER=$(usex weathersat)

		-DOPT_BUILD_DISCORD_PRESENCE=$(usex discord)
		-DOPT_BUILD_FREQUENCY_MANAGER=$(usex frecuencymanager)
		-DOPT_BUILD_RECORDER=$(usex recorder)
		-DOPT_BUILD_RIGCTL_SERVER=$(usex rigctlserver)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Create a symlink because SDRPP only looks for plugins in /usr/lib, but
	# Gentoo is very tidy and puts them in /usr/lib64.
	if [ -d "${ED}/usr/lib64/sdrpp" ]; then
		dosym /usr/lib64/sdrpp /usr/lib/sdrpp
	fi
}
