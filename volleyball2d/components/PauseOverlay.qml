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

ScaleItem {
    objectName: "pauseOverlay"

    // Hack for autopilot otherwise PointOverlay appears as ScaleItem
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

    signal endGame()
    signal pause()
    signal resume()

    Rectangle {
        anchors {
            fill: parent
        }
        color: "#000"
        opacity: .6
    }

    MouseArea {
        anchors {
            fill: parent
        }
    }

    Column {
        anchors {
            centerIn: parent
        }
        spacing: units.gu(2)

        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: "#FFF"
            fontSize: "x-large"
            text: i18n.tr("Paused")
        }

        Button {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            objectName: "continue"
            text: i18n.tr("Continue")
            onClicked: resume()
        }

        Button {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            objectName: "returnToMenu"
            text: i18n.tr("Return to menu")
            onClicked: endGame()
        }
    }
}
