/*
 * Copyright (C) 2014, 2015
 *      Andrew Hayzen <ahayzen@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Bacon2D 1.0
import Ubuntu.Components 1.3
import QtFeedback 5.0
import QtQuick 2.3
import QtSensors 5.3
import "../components"

Scene {
    id: gameScene
    anchors {
        fill: parent
    }
    gravity: Qt.point(0, 20)
    objectName: "gameScene"
    pixelsPerMeter: units.gu(3)
    physics: true

    property int netDepth: units.gu(1)
    property int wallDepth: units.gu(.5)
    property Character lastWinner

    property int modeFirstToX: 0
    property int modeHighestScore: 1
    property int modeSurvival: 2

    property Wall centreNet: net.centre
    property Wall ground: boundary.ground

    signal endGame()
    signal gameFinished(Character human, Character computer, int time)
    signal pause()
    signal resume()
    signal roundWon(Character winner, Character human, Character computer, int time)

    // Scoring for the players
    Scoring {
        player: human
        opponent: computer
    }

    // Level boundaries
    Boundaries {
        id: boundary
        wallDepth: parent.wallDepth
    }

    // Net in centre
    Net {
        id: net
        netDepth: parent.netDepth
    }

    // Volley Ball
    Ball {
        id: volleyball
        onContact: {
            if (gameScene.running) {
                rumbleEffect.start()

                if (other === ground) {
                    roundWon(x < parent.width / 2 ? computer : human, human, computer, gameHeader.time)
                }
            }
        }
        onXChanged: volleyBallHint.x = volleyball.getWorldCenter().x

        HapticsEffect {
            id: rumbleEffect
            duration: 10
        }
    }

    // Hint of where the ball is when it goes offscreen (above)
    Rectangle {
        id: volleyBallHint
        anchors {
            top: parent.top
        }
        color: volleyball.color
        height: width / 2
        width: volleyball.radius
        visible: volleyball.y < y
    }

    // Character
    Human {
        id: human
        objectName: "human"
    }

    // Enemy
    Computer {
        id: computer
        ball: volleyball
        enemy: human
        gravity: gameScene.gravity
        minX: centreNet.x + centreNet.width
        maxX: gameScene.width
        objectName: "computer"
    }

    // AI Prediction DEBUG
    AIDebug {
        id: aiDebug
    }

    // Tap controls
    MultiPointTouchArea {
        id: multiTouchArea
        anchors {
            fill: parent
        }
        enabled: !settings.useMotion
        minimumTouchPoints: 1
        maximumTouchPoints: 2
        touchPoints: [
            TouchPoint {
                id: point1
                onPressedChanged: {
                    if (pressed) {
                        if (multiTouchArea.inLeft(x)) {
                            human.leftPressed = true
                            human.rightPressed = false
                        } else if (multiTouchArea.inCenter(x)) {
                            human.jump()
                        } else if (multiTouchArea.inRight(x)) {
                            human.leftPressed = false
                            human.rightPressed = true
                        }
                    } else {
                        human.leftPressed = false
                        human.rightPressed = false
                    }
                }
            },
            TouchPoint {
                id: point2
                onPressedChanged: {
                    if (pressed) {
                        if (!multiTouchArea.inCenter(point1.x)) {
                            human.jump();
                        } else {
                            if (multiTouchArea.inLeft(x)) {
                                human.leftPressed = true
                                human.rightPressed = false
                            } else if (multiTouchArea.inRight(x)) {
                                human.leftPressed = false
                                human.rightPressed = true
                            }
                        }
                    }
                }
            }
        ]

        function inCenter(x) {
            return !inLeft(x) && !inRight(x);
        }

        function inLeft(x) {
            return x < gameScene.width / 3;
        }

        function inRight(x) {
            return x > gameScene.width - (gameScene.width / 3)
        }
    }

    // Motion controls
    MouseArea {
        anchors {
            fill: parent
        }
        enabled: settings.useMotion
        onPressed: human.upPressed = true
        onReleased: human.upPressed = false
    }

    OrientationSensor {
        id: orientationSensor
        active: tiltSensor.active
    }

    TiltSensor {
        id: tiltSensor
        active: settings.useMotion && gameScene.running
        dataRate: 16

        function getScalar(amount) {
            // Make a scale from 0 -> 2
            // from 0deg -> 20/40deg
            // sensitivity can be 0.5 - 1
            var scalar = (Math.abs(amount) / 10) * settings.motionSensitivity

            if (scalar > human.scalarLimit) {
                scalar = human.scalarLimit
            }

            return scalar;
        }

        onReadingChanged: {
            if (orientationSensor.reading.orientation === OrientationReading.TopUp) {
                human.leftPressed = reading.yRotation < -settings.motionDeadZone ? getScalar(reading.yRotation) : false
                human.rightPressed = reading.yRotation > settings.motionDeadZone ? getScalar(reading.yRotation) : false
            } else if (orientationSensor.reading.orientation === OrientationReading.TopDown) {
                human.leftPressed = reading.yRotation < -settings.motionDeadZone ? false : getScalar(reading.yRotation)
                human.rightPressed = reading.yRotation > settings.motionDeadZone ? false : getScalar(reading.yRotation)
            } else if (orientationSensor.reading.orientation === OrientationReading.RightUp) {
                human.leftPressed = reading.xRotation < -settings.motionDeadZone ? getScalar(reading.xRotation) : false
                human.rightPressed = reading.xRotation > settings.motionDeadZone ? getScalar(reading.xRotation) : false
            } else if (orientationSensor.reading.orientation === OrientationReading.LeftUp) {
                human.leftPressed = reading.xRotation < -settings.motionDeadZone ? false : getScalar(reading.xRotation)
                human.rightPressed = reading.xRotation > settings.motionDeadZone ? false : getScalar(reading.xRotation)
            }
        }
    }

    // Header
    GameHeader {
        id: gameHeader
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.top
        }
        onTimeZero: {  // time has reached zero
            if (settings.gameMode === modeHighestScore) {
                gameFinished(human, computer, time);
            }
        }
    }

    // Keyboard controls
    // TODO: add scaling
    Keys.onEscapePressed: {
        if (pointOverlayLoader.visible) {
            gameScene.reset();
        } else {
            if (pauseOverlayLoader.visible) {
                resume()
            } else {
                pause()
            }
        }
    }

    Keys.onReturnPressed: {
        if (pointOverlayLoader.visible) {
            gameScene.reset();
        }
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat) {
            switch (event.key) {
            case Qt.Key_Left:
                human.leftPressed = 1;
                break;
            case Qt.Key_Right:
                human.rightPressed = 1;
                break;
            case Qt.Key_Space:
            case Qt.Key_Up:
                human.upPressed = true;
                break;
            }
        }
    }

    Keys.onReleased: {
        if (!event.isAutoRepeat) {
            switch (event.key) {
            case Qt.Key_Left:
                human.leftPressed = false;
                break;
            case Qt.Key_Right:
                human.rightPressed = false;
                break;
            case Qt.Key_Space:
            case Qt.Key_Up:
                human.upPressed = false;
                break;
            }
        }
    }

    // Game has ended restart
    function restart() {
        // Reset scores, timer and lastwinner
        lastWinner = null;
        human.score = 0;
        computer.score = 0;
        gameHeader.time = settings.gameMode === modeHighestScore ? settings.highestScoreTime : 0;
        gameHeader.increment = settings.gameMode === modeHighestScore ? -1 : 1;

        reset();  // reset positions
    }

    // Reset the sprites between points
    function reset() {
        pauseOverlayLoader.visible = false;
        pointOverlayLoader.visible = false;

        // Zero any velocities
        volleyball.angularVelocity = 0.0;
        volleyball.rotation = 0;
        volleyball.linearVelocity = Qt.point(0, 0);
        human.linearVelocity = Qt.point(0, 0);
        computer.linearVelocity = Qt.point(0, 0);

        // Reset controls
        human.leftPressed = false;
        human.rightPressed = false;
        human.upPressed = false;

        // Reset volleyball
        if (lastWinner === computer) {
            volleyball.x = gameScene.width - gameScene.width / 4;
        } else {
            volleyball.x = gameScene.width / 4;
        }

        volleyball.y = gameScene.height / 2;

        // Reset human
        human.x = (gameScene.width / 4) - human.radius;
        human.y = gameScene.height - human.radius;

        // Reset computer
        computer.x = gameScene.width - (gameScene.width / 4) - computer.radius;
        computer.y = gameScene.height - computer.radius;

        // Restart the game
        resume()

        // Ensure focus is correct
        gameScene.forceActiveFocus()
    }
}
