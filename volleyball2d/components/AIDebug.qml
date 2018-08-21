/*
 * Copyright (C) 2014
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
    anchors {
        fill: parent
    }
    visible: settings.aiDebugLayer

    property point actual: Qt.point(0, 0)
    property alias angle: aiPredAngle.rotation
    property point highest: Qt.point(0, 0)
    property point landing: Qt.point(0, 0)
    property point target: Qt.point(0, 0)
    property alias text: aiPredText.text

    // X actual landing
    Rectangle {
        id: aiPredX
        color: "#F00"
        height: parent.height - wallDepth
        width: wallDepth / 2
        x: landing.x
        y: 0
    }

    // Y actual landing
    Rectangle {
        id: aiPredY
        color: "#00F"
        height: wallDepth / 2
        width: parent.width
        x: 0
        y: highest.y
    }

    // X target
    Rectangle {
        id: aiPredXTarget
        color: "#0F0"
        height: parent.height - wallDepth
        width: wallDepth / 2
        x: target.x
        y: 0
    }

    // X actual (post random)
    Rectangle {
        id: aiPredXTargetPreRand
        color: "#800080"
        height: parent.height - wallDepth
        width: wallDepth / 2
        x: actual.x
        y: 0
    }

    // Ball angle
    Rectangle {
        id: aiPredAngle
        color: "#555"
        height: units.gu(10)
        width: units.gu(.5)
        x: landing.x
        y: landing.y - height
    }

    // Helper text
    Label {
        id: aiPredText
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
    }
}
