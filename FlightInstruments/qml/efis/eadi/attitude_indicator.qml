import QtQuick 2.15

Item {
  id: root
  width: 300
  height: 300
  clip: true

  property double pitch: 0
  property double roll: 0
  property double slipSkid: 0
  property double sideSlipAngle: 0
  property double angleOfAttack: 0

  property double turnRate: 0
  property double dotH: 0
  property double dotV: 0
  property double fdPitch: 0
  property double fdRoll: 0

  property bool dotHVisible: true
  property bool dotVVisible: true
  property bool fdVisible: true
  property bool stallVisible: false

  // private
  readonly property double pixelPerDegree: 3

  property double backDeltaY: 0
  property double fdDeltaX: 0
  property double fdDeltaY: 0
  property double displayPitch: 0
  property bool inverted: false

  onPitchChanged: update()
  onFdPitchChanged: update()

  function update() {
    // Wrap pitch into -180..180. Past 90 degrees the aircraft is inverted;
    // flip the horizon instead of clamping the instrument at +-17 degrees.
    var p = pitch
    p = p - 360 * Math.floor((p + 180) / 360)
    inverted = (p >= 90 || p <= -90)
    displayPitch = p
    if (p > 90)
      displayPitch = 180 - p
    else if (p < -90)
      displayPitch = -180 - p

    backDeltaY = pixelPerDegree * displayPitch

    var temp = displayPitch - fdPitch

    if (temp < -17.0)
      temp = -17.0
    else if (temp > 17.0)
      temp = 17.0

    fdDeltaX = temp * pixelPerDegree * Math.sin(roll * Math.PI / 180)
    fdDeltaY = temp * pixelPerDegree * Math.cos(roll * Math.PI / 180)
  }

  Item {
    id: back
    x: 45
    y: -85
    width: 210
    height: 420
    transform: [
      Rotation {
        origin.x: (150 - 45)
        origin.y: (125 + 85)
        axis {
          x: 0
          y: 0
          z: 1
        }
        angle: -roll + (inverted ? 180 : 0)
      },
      Translate {
        x: backDeltaY * Math.sin(roll * Math.PI / 180)
        y: backDeltaY * Math.cos(roll * Math.PI / 180)
      }
    ]

    // A large sky/ground plane rather than a finite 420 px image. This keeps
    // the horizon filled at 90/180/270 degrees instead of exposing black.
    Rectangle {
      x: -495
      y: -600
      width: 1200
      height: 600
      color: "#2f7fd3"
    }

    Rectangle {
      x: -495
      y: 0
      width: 1200
      height: 600
      color: "#7a4f24"
    }

    Rectangle {
      x: -495
      y: -1
      width: 1200
      height: 2
      color: "#d8d8d8"
      opacity: 0.65
    }
  }

  EadiImage {
    id: ladder
    x: 110
    y: -175
    width: 80
    source: "qrc:/images/eadi_adi_ladd.svg"
    sourceSize.height: 2400
    sourceSize.width: 320
    transform: [
      Rotation {
        origin.x: (150 - 110)
        origin.y: (125 + 175)
        axis {
          x: 0
          y: 0
          z: 1
        }
        angle: -roll + (inverted ? 180 : 0)
      },

      Translate {
        x: pixelPerDegree * displayPitch * Math.sin(roll * Math.PI / 180)
        y: pixelPerDegree * displayPitch * Math.cos(roll * Math.PI / 180)
      }
    ]
  }

  EadiImage {
    id: rollMask
    x: 45
    y: 20
    width: 210
    source: "qrc:/images/eadi_adi_roll.svg"
    sourceSize.height: 840
    sourceSize.width: 840
    transform: Rotation {
      origin.x: (150 - 45)
      origin.y: (125 - 20)
      axis {
        x: 0
        y: 0
        z: 1
      }
      angle: -roll
    }
  }

  EadiImage {
    id: slip
    x: 145.5
    y: 68
    width: 9
    source: "qrc:/images/eadi_adi_slip.svg"
    sourceSize.height: 12
    sourceSize.width: 36
    transform: [
      Rotation {
        origin.x: (150 - 145.5)
        origin.y: (125 - 68)
        axis {
          x: 0
          y: 0
          z: 1
        }
        angle: -roll
      },

      Translate {
        x: -20 * slipSkid * Math.cos(roll * Math.PI / 180)
        y: 20 * slipSkid * Math.sin(roll * Math.PI / 180)
      }
    ]
  }

  EadiImage {
    id: doth
    x: 145
    y: 188
    width: 10
    source: "qrc:/images/eadi_adi_doth.svg"
    sourceSize.height: 40
    sourceSize.width: 40
    visible: dotHVisible
    transform: Translate {
      x: 50 * dotH
    }
  }

  EadiImage {
    id: dotv
    x: 213
    y: 120
    width: 10
    source: "qrc:/images/eadi_adi_dotv.svg"
    sourceSize.height: 40
    sourceSize.width: 40
    visible: dotVVisible
    transform: Translate {
      y: -50 * dotV
    }
  }

  EadiImage {
    id: scaleH
    x: 0
    y: 0
    width: 300
    source: "qrc:/images/eadi_adi_scaleh.svg"
    sourceSize.height: 1200
    sourceSize.width: 1200
    visible: dotHVisible
  }

  EadiImage {
    id: scaleV
    x: 0
    y: 0
    width: 300
    source: "qrc:/images/eadi_adi_scalev.svg"
    sourceSize.height: 1200
    sourceSize.width: 1200
    visible: dotVVisible
  }

  EadiImage {
    id: fd
    x: 107
    y: 124.5
    height: 18
    source: "qrc:/images/eadi_adi_fd.svg"
    sourceSize.height: 72
    sourceSize.width: 344
    visible: fdVisible
    transform: [
      Rotation {
        origin.x: (150 - 107)
        origin.y: (125 - 124.5)
        axis {
          x: 0
          y: 0
          z: 1
        }
        angle: fdRoll - roll
      },
      Translate {
        x: fdDeltaX
        y: fdDeltaY
      }
    ]
  }

  EadiImage {
    id: fpm
    x: 135
    y: 113
    height: 19
    source: "qrc:/images/eadi_adi_fpm.svg"
    sourceSize.height: 76
    sourceSize.width: 120
    transform: Translate {
      x: pixelPerDegree * sideSlipAngle
      y: -pixelPerDegree * angleOfAttack
    }
  }

  EadiImage {
    id: fpmx
    x: 135
    y: 113
    height: 19
    source: "qrc:/images/eadi_adi_fpmx.svg"
    sourceSize.height: 76
    sourceSize.width: 120
    transform: Translate {
      x: pixelPerDegree * sideSlipAngle
      y: -pixelPerDegree * angleOfAttack
    }
    visible: Math.abs(sideSlipAngle) >= 15 || Math.abs(angleOfAttack) >= 20
  }

  EadiImage {
    id: mask
    x: 0
    y: 0
    height: 300
    source: "qrc:/images/eadi_adi_mask.svg"
    sourceSize.height: 1200
    sourceSize.width: 1200
  }

  EadiImage {
    id: turn
    x: 142.5
    y: 206
    height: 4
    source: "qrc:/images/eadi_adi_turn.svg"
    sourceSize.height: 16
    sourceSize.width: 60
    transform: Translate {
      x: 55 * turnRate
    }
  }

  EadiImage {
    id: stall
    x: 122
    y: 91
    width: 56
    source: "qrc:/images/eadi_adi_stall.svg"
    sourceSize.height: 140
    sourceSize.width: 560
    visible: stallVisible
  }
}
