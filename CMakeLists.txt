cmake_minimum_required(VERSION 3.20)

project(asteroid-skedaddle
	VERSION 0.0.1
	DESCRIPTION "Runner's tracking app for AsteroidOS"
        )

find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

add_subdirectory(src)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/runscript.in
	${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}
	@ONLY)

install(PROGRAMS ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}
	DESTINATION ${CMAKE_INSTALL_BINDIR})

build_translations(i18n)
generate_desktop(${CMAKE_SOURCE_DIR} ${CMAKE_PROJECT_NAME})

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
