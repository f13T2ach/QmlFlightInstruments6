import QtQuick 2.0

Item {
  width: 2 * radius
  height: 2 * radius

  required property double radius

  // Normalized inputs, -1..1 (see PrimaryFlightData).
  property double turnRate: 0
  property double slipSkid: 0

  // Visual deflection at full scale.
  readonly property double turnRateFullScaleAngle: 20
  readonly property double slipSkidFullScaleAngle: 15

  BasicSixImage {
    anchors.fill: parent
    source: "qrc:/images/tc_back.svg"
  }

  BasicSixImage {
    id: ball
    anchors.fill: parent
    source: "qrc:/images/tc_ball.svg"
    transform: Rotation {
      origin.x: 0.5 * ball.width
      origin.y: -36 / 240 * ball.height
      axis {
        x: 0
        y: 0
        z: 1
      }
      angle: slipSkidFullScaleAngle * slipSkid
    }
  }

  BasicSixImage {
    anchors.fill: parent
    source: "qrc:/images/tc_face_1.svg"
  }

  BasicSixImage {
    anchors.fill: parent
    source: "qrc:/images/tc_face_2.svg"
  }

  BasicSixImage {
    anchors.fill: parent
    source: "qrc:/images/tc_mark.svg"
    rotation: turnRateFullScaleAngle * turnRate
  }

  BasicSixImage {
    anchors.fill: parent
    source: "qrc:/images/tc_case.svg"
  }
}
