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

import QtQuick 2.3
import Ubuntu.Components 1.3


Item {
    height: textColumn.childrenRect.height * 2 + units.gu(1)
    width: textColumn.childrenRect.width + bgFill.radius * 2

    property alias increment: timeTimer.increment
    property alias text: pauseLabel.text
    property alias time: timeTimer.time

    signal timeZero()

    Rectangle {
        id: bgFill
        anchors {
            fill: parent
        }
        antialiasing: true
        color: "#000"
        opacity: .5
        radius: height / 2
        smooth: true
    }

    MouseArea {
        anchors {
            fill: parent
        }

        function inCircle(circle, r, mouse) {
            return Math.sqrt((mouse.y - circle.y) * (mouse.y - circle.y)
                             + (mouse.x - circle.x) * (mouse.x - circle.x)) < r;
        }

        onClicked: {
            var radius = bgFill.radius

            if ((mouse.x > x + radius && mouse.x < x + width - radius)
                    || inCircle(Qt.point(x + radius, y + height / 2), radius, mouse)
                    || inCircle(Qt.point(x + width - radius, y + height / 2), radius, mouse)) {
                pause()
            }
        }
    }

    Column {
        id: textColumn
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
        }

        Label {
            id: timeLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: "#FFF"
            text: timeToString(timeTimer.time)

            function timeToString(time) {
                var minutes = Math.floor(time / 60);
                var seconds = Math.floor(time % 60);

                if (minutes.toString() == "NaN") {
                    minutes = 0
                }
                if (seconds.toString() == "NaN") {
                    seconds = 0
                }

                return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
            }

            Timer {
                id: timeTimer
                repeat: true
                interval: 1000
                running: gameScene.running
                onTriggered: {
                    time += increment

                    if (time === 0) {
                        timeZero()
                    }
                }

                property int increment: 1
                property int time: 0
            }
        }

        Label {
            id: pauseLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: "#FFF"
            objectName: "pauseLabel"
            text: i18n.tr("Pause")
        }
    }
}
