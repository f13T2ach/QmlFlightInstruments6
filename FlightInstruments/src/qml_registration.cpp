#include "qml_registration.h"

#include <QByteArray>
#include <QDir>
#include <QFileInfo>
#include <QUrl>
#include <QtQml/qqml.h>

namespace FlightInstruments {

void registerQmlTypes()
{
    // The legacy QmlFlightInstruments.qrc stores every instrument under an
    // alias whose basename is the QML type name, e.g.
    //   AirspeedIndicatorBasicSix.qml -> AirspeedIndicatorBasicSix
    // Enumerating the resource directory keeps this list in sync with the
    // library automatically when instruments are added or removed.
    const QDir dir(QStringLiteral(":/qml"));
    const QFileInfoList files =
        dir.entryInfoList({QStringLiteral("*.qml")}, QDir::Files, QDir::Name);

    for (const QFileInfo &file : files) {
        const QByteArray typeName = file.completeBaseName().toUtf8();
        qmlRegisterType(QUrl(QStringLiteral("qrc:/qml/") + file.fileName()),
                        "FlightInstruments", 1, 0, typeName.constData());
    }
}

} // namespace FlightInstruments
