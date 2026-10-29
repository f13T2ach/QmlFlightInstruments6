import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

import FlightInstruments

Window {
  id: rootWindow
  visible: true
  width: 1440
  height: 900
  minimumWidth: 1200
  minimumHeight: 700
  title: "QML Flight Instruments"
  color: "#0d0d0d" // Deeper cockpit black

  FontLoader {
    source: "qrc:/fonts/CenturyGothic.ttf"
  }

  // Actual instrument bounds in design coordinates, used for centering.
  readonly property real contentLeft: 145
  readonly property real contentTop: 30
  readonly property real contentWidth: 1200 // 1345 - 145
  readonly property real contentHeight: 860 // 890 - 30

  readonly property bool isFullScreen: visibility === Window.FullScreen

  // Windowed mode scales the 1440x900 design canvas. Fullscreen fits the
  // content to the screen, capped at 1.25x (about 1.24x on 2560x1600 @150%).
  property real s: isFullScreen
                  ? Math.min(width / contentWidth, height / contentHeight, 1.25)
                  : Math.min(width / 1440, height / 900)

  function toggleFullScreen() {
    if (visibility === Window.FullScreen) {
      visibility = Window.Windowed
      width = 1440
      height = 900
    } else {
      visibility = Window.FullScreen
    }
  }

  Shortcut {
    sequence: "F11"
    onActivated: rootWindow.toggleFullScreen()
  }

  Shortcut {
    sequence: "Esc"
    onActivated: {
      if (rootWindow.isFullScreen)
        rootWindow.toggleFullScreen()
    }
  }

  // Fixed design canvas so instrument placement is independent of window size.
  Item {
    id: cockpit
    width: 1440
    height: 900
    scale: rootWindow.s
    transformOrigin: Item.TopLeft
    x: (rootWindow.width - rootWindow.contentWidth * rootWindow.s) / 2 - rootWindow.contentLeft * rootWindow.s
    y: (rootWindow.height - rootWindow.contentHeight * rootWindow.s) / 2 - rootWindow.contentTop * rootWindow.s

    // ==========================================
    // Center Primary Flight Display (EADI)
    // ==========================================
    Rectangle {
      id: eadiPanel
      x: 395
      y: 30
      width: 650
      height: 650
      radius: 14
      color: "#000000"
      border.color: "#3a3a3a"
      border.width: 1

      ElectronicAttitudeDirectionIndicator {
        anchors.centerIn: parent
        scale: 2.1 // EADI is authored at 300x300; scale it to fill the center panel
        scaleRatio: 2.1 // Render speed, altitude and VSI tapes at 2.1x resolution
        transformOrigin: Item.Center

        adi.angleOfAttack: flight_telemetry.angleOfAttack
        adi.sideSlipAngle: flight_telemetry.angleOfSideSlip
        adi.roll: flight_telemetry.roll
        adi.pitch: flight_telemetry.pitch
        adi.slipSkid: flight_telemetry.slipSkid
        adi.turnRate: flight_telemetry.turnRate
        adi.dotH: flight_telemetry.ilsLOC
        adi.dotV: flight_telemetry.ilsGS
        adi.fdPitch: flight_telemetry.fdPitch
        adi.fdRoll: flight_telemetry.fdRoll
        adi.dotHVisible: flight_telemetry.ilsLOCVisible
        adi.dotVVisible: flight_telemetry.ilsGSVisible
        adi.fdVisible: flight_telemetry.fdVisible
        adi.stallVisible: flight_telemetry.stall

        asi.airspeed: flight_telemetry.airspeed
        asi.bugValue: flight_telemetry.airspeedBug
        alt.altitude: flight_telemetry.altitude
        alt.bugValue: flight_telemetry.altitudeBug
        hsi.heading: flight_telemetry.heading
        hsi.bugValue: flight_telemetry.headingBug
        vsi.climbRate: flight_telemetry.climbRate

        labels.airspeedBug: flight_telemetry.airspeedBug
        labels.machNumber: flight_telemetry.machNumber
        labels.altitudeBug: flight_telemetry.altitudeBug
        labels.pressure: flight_telemetry.pressure
        labels.pressureMode: flight_telemetry.pressureMode
        labels.flightMode: flight_telemetry.flightMode
        labels.speedMode: flight_telemetry.speedMode
        labels.lnav: flight_telemetry.lateralNavigationMode
        labels.vnav: flight_telemetry.verticalNavigationMode
      }
    }

    // ==========================================
    // Left Basic Six (ASI / Turn Coordinator / HI)
    // ==========================================
    Column {
      x: 145
      y: 30
      spacing: 25

      Item {
        width: 200
        height: 200

        AirspeedIndicatorBasicSix {
          anchors.centerIn: parent
          radius: 100
          airspeed: flight_telemetry.airspeed
        }
      }

      Item {
        width: 200
        height: 200

        TurnCoordinatorBasicSix {
          anchors.centerIn: parent
          radius: 100
          turnRate: flight_telemetry.turnRate
          slipSkid: flight_telemetry.slipSkid
        }
      }

      Item {
        width: 200
        height: 200

        HeadingIndicatorBasicSix {
          anchors.centerIn: parent
          radius: 100
          heading: flight_telemetry.heading
        }
      }
    }

    // ==========================================
    // Right Basic Six (ALT / EHSI / VSI)
    // ==========================================
    Column {
      x: 1060
      y: 20
      spacing: 10

      Item {
        width: 300
        height: 190

        AltimeterBasicSix {
          anchors.centerIn: parent
          radius: 95
          altitude: flight_telemetry.altitude
          pressure: flight_telemetry.pressure
        }
      }

      Item {
        width: 300
        height: 270

        ElectronicHorizontalSituationIndicator {
          anchors.centerIn: parent
          scale: 0.9
          transformOrigin: Item.Center

          heading: flight_telemetry.heading
          course: flight_telemetry.course
          bearing: flight_telemetry.bearing
          deviation: flight_telemetry.vorDeviation
          headingBug: flight_telemetry.headingBug
          distance: flight_telemetry.dmeDistance
          cdiMode: flight_telemetry.courseDeviationIndicatorMode
        }
      }

      Item {
        width: 300
        height: 190

        VerticalSpeedIndicatorBasicSix {
          anchors.centerIn: parent
          radius: 95
          climbRate: flight_telemetry.climbRate
        }
      }
    }

    // ==========================================
    // Bottom Engine and System Gauges
    // ==========================================
    Row {
      id: bottomRow
      x: 217
      y: 700
      spacing: 14

      TankGauge {
        radius: 95
        leftTankFuel: flight_telemetry.leftTankFuel
        rightTankFuel: flight_telemetry.rightTankFuel
      }
      EgtFuelFlowGauge {
        radius: 95
        egt: flight_telemetry.egt
        fuelFlow: flight_telemetry.fuelFlow
      }
      PropellerGauge {
        radius: 95
        rpm: flight_telemetry.rpm
      }
      VacAmpGauge {
        radius: 95
        vac: flight_telemetry.vac
        amp: flight_telemetry.amp
      }
      TemperaturePressureGauge {
        radius: 95
        engineTemperature: flight_telemetry.engineTemperature
        enginePressure: flight_telemetry.enginePressure
      }
    }
  }

  // Fullscreen button: windowed by default; fullscreen scales the cockpit to fit.
  Rectangle {
    id: fullScreenButton
    width: rootWindow.isFullScreen ? 76 : 58
    height: 30
    radius: 6
    color: fullScreenMouse.containsMouse ? "#2b2b2b" : "#161616"
    border.color: "#4a4a4a"
    border.width: 1
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.margins: 10
    z: 100

    Text {
      anchors.centerIn: parent
      text: rootWindow.isFullScreen ? "Exit" : "Full"
      color: "#cccccc"
      font.pixelSize: 12
    }

    MouseArea {
      id: fullScreenMouse
      anchors.fill: parent
      hoverEnabled: true
      onClicked: rootWindow.toggleFullScreen()
    }
  }
}
