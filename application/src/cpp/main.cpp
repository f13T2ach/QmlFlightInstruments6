#include <QGuiApplication>
#include <QtQml/QtQml>

#include "animation.h"
#include "primary_flight_data.h"
#include "qml_registration.h"

int main(int argc, char* argv[]) {
  // Initialize resources from the static QmlFlightInstruments module.
  // This must be done from the final executable (not from inside another
  // static library). It is required for the images, fonts, and legacy
  // qrc:/qml/... paths used by the instrument components.
  Q_INIT_RESOURCE(QmlFlightInstruments);

  // Register the QML-file based instrument types shipped with the static module.
  FlightInstruments::registerQmlTypes();

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
  const QGuiApplication Application(argc, argv);

  QQmlApplicationEngine engine;

  const QUrl RootUrl("qrc:/qml/MainWindow.qml");
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreated, &Application,
      [RootUrl](const QObject* object, const QUrl& object_url) {
        if (!object && RootUrl == object_url)
          QCoreApplication::exit(-1);
      },
      Qt::QueuedConnection);

  auto* flight_telemetry = new PrimaryFlightData;
  auto* animation = new Animation;
  animation->setPfd(flight_telemetry);

  engine.rootContext()->setContextProperty("flight_telemetry", flight_telemetry);
  engine.load(RootUrl);

  animation->init();

  return Application.exec();
}
