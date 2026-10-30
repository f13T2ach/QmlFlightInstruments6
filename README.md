# QML Flight Instruments

This is a submodule project, supports my another project **flight**

This project provides more components and features.

This is an update of [Berkbavas QML port](https://github.com/berkbavas/QmlFlightInstruments)
of [Marek M. Cel](http://marekcel.pl/)'
s [QFlightinstruments](https://github.com/marek-cel/QFlightinstruments). This update:

- Is compatible with Qt6 (tested against 6.12.0). This required many changes, including the replacement of the Qt Quick
  Extras CircularGauge with a custom circular gauge.
- Replaces the Qt project structure with a pure CMake build system
- The Flight Instruments are now in a seperate module. The demo app has been updated to reflect this change.

SVG files are from Marek's repository. See `application/ui/images/LICENSE` for copyright.

## Features

- **Electronic Flight Instrument System (EFIS)**
    - Electronic Attitude Direction Indicator (EADI)
    - Electronic Horizontal Situation Indicator (EHSI)
- **Basic Six**
    - Airspeed Indicator (ASI)
    - Attitude Indicator (AI)
    - Altimeter (ALT)
    - Turn Coordinator (TC)
    - Heading Indicator (HI)
    - Vertical Speed Indicator (VSI)
- **Additional Gauges**
    - Fuel Tank
    - Exhaust Gas Temperature (EGT) & Fuel Flow
    - Propeller
    - Battery
    - Temperature & Pressure

## Building (standalone demo)

1. Install **Qt 6.11.0** or **Qt 6.12.0**.
2. Open `CMakeLists.txt` in **Your IDE Of Choice**.
3. Update the root `CMakeLists.txt` file to reflect your **QT_INSTALL_LOCATION** and **QT_VERSION_TO_USE**
    - Optionally, update **APPLICATION_URI**, **APPLICATION_BUNDLE_GUI_ID** and **APPLICATION_ICON_PATH** for macOS
      deployment
4. Build and run the project.

Tested on macOS, Windows. **Aerospyke** claims that it would be also transplanted to linux platform.

## Usage Guide

Reference the application sub project to see how to use the Flight Instruments module in your own application. Some key
points:

1. In the consuming project's CMakeLists.txt
    - Add the Flight instruments module (adjust the path to wherever you placed / submodule'd this repo)
        - for example, if you copied the module to ${project_root}/qml-flight-instruments,

```cmake 
      add_subdirectory(${CMAKE_SOURCE_DIR}/QmlFlightInstruments6)
```

2. Link the module/static library

```cmake
set(LINKED_LIBRARIES_INTERNAL
        QmlFlightInstruments
        # ... other internal libs
)
```

3. Because the instruments are delivered as a *static* library, you must also call Q_INIT_RESOURCE from one of your
   executable's .cpp files (typically the very first thing in main(), before creating the QGuiApplication
   or QQmlApplicationEngine). This is required so that the images, fonts, and legacy qrc:/qml/... paths are registered.
   Immediately after that, call `FlightInstruments::registerQmlTypes()` to register the QML-file based instrument types
   (`AirspeedIndicatorBasicSix`, `EgtFuelFlowGauge`, ...). The module's generated qmldir only lists C++ types, so this
   call is required before any QML file imports `FlightInstruments`. The helper enumerates the aliases in the library's
   qrc at runtime, so instruments added to the library are registered automatically.

```C++
#include "qml_registration.h"

Q_INIT_RESOURCE(QmlFlightInstruments);
FlightInstruments::registerQmlTypes();
```

4. Loading QML Resources in the consuming app

- Classic resource loading (no changes required to most existing instrument QML):

```qml
// Load a full pre-built display as a Window (or use the individual gauges inside your own UI)
Loader {
    source: "qrc:/qml/EfisRootDisplay.qml"
}
```

- With the QML module import:

```qml
import FlightInstruments

Item {
    // PrimaryFlightData is registered as a QML type thanks to qt_add_qml_module
    PrimaryFlightData {
        id: telemetry
        // bind properties from your own data source / model here
    }

    ElectronicAttitudeDirectionIndicator {
        // bind the various adi/asi/alt/... properties to telemetry.*
    }
}
```

See `FlightInstruments/CMakeLists.txt` for the exact target name and alias (
`QmlFlightInstruments::QmlFlightInstruments`).

## Credits & License

- Transplanted by  [qml-flight-instruments](https://github.com/Aerospyke/qml-flight-instruments).
- Original code and SVGs by Marek M. Cel. See [QFlightinstruments](https://github.com/marek-cel/QFlightinstruments).
- Additional gauges and QML port by this project.
- This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
