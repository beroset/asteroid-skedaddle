cmake_minimum_required(VERSION 3.20)

project(asteroid-skedaddle
	VERSION 1.0.1
	DESCRIPTION "Runner's tracking app for AsteroidOS"
        )

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMFindQmlModule)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

find_package(Qt5 COMPONENTS Core Qml Quick Location Positioning REQUIRED)

build_translations(i18n)
generate_desktop(${CMAKE_SOURCE_DIR} ${CMAKE_PROJECT_NAME})

add_subdirectory(src)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
