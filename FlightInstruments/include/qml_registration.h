#pragma once

namespace FlightInstruments {

// Register every QML-file based instrument type shipped in the library.
//
// The static QML module itself only exposes C++ types through its generated
// qmldir, so consumers that load a plain .qml file from qrc must call this
// once after Q_INIT_RESOURCE(QmlFlightInstruments) and before the QML engine
// imports FlightInstruments.
void registerQmlTypes();

} // namespace FlightInstruments
