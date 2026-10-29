cmake_minimum_required(VERSION 4.1)
project(qml-flight-instruments)

include(QtAppSetup.cmake)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install-target")

# Set your QT Install Location and Version Tag Here! /Users/${username}/Qt/6.11.0/macos is a typical macOS installation
# X:\\Qt\\6.12.0\\mingw_64 is a typical Windows installation
set(QT_INSTALL_LOCATION "D:\\Qt\\6.12.0\\mingw_64")
set(QT_VERSION_TO_USE 6.12)
# Set your custom build information here (Bundle ID and Icon Path are needed for macOS deployment)
set(APPLICATION_URI flight_instruments_demo)
set(APPLICATION_BUNDLE_GUI_ID de.conorco.flight_instruments_demo)
set(APPLICATION_ICON_PATH ${CMAKE_CURRENT_SOURCE_DIR}/application/ui/icons/conor_co.icns)

set(APPLICATION_NAME "QmlFlightInstrumentsDemo")

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(QT_QML_GENERATE_QML_CACHE ON)
set(CMAKE_AUTOMAC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
list(APPEND CMAKE_PREFIX_PATH ${QT_INSTALL_LOCATION})

# Find Qt once at the root so that all subdirectories (including the reusable
# FlightInstruments module) can safely use qt_add_library / qt_add_qml_module etc.
find_package(Qt6 ${QT_VERSION_TO_USE} COMPONENTS
        Core
        Gui
        Quick
        Graphs
        ShaderTools
        QuickLayouts
        QuickControls2
        REQUIRED
)

if (QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 NEW)
endif ()

qt_standard_project_setup(REQUIRES ${QT_VERSION_TO_USE})

add_subdirectory(FlightInstruments)
add_subdirectory(application)
