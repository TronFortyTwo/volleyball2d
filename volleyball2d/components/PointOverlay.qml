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
    objectName: "pointOverlay"

    property bool userWon: false

    signal close()

    Rectangle {
        anchors {
            fill: parent
        }
        color: "#000"
        opacity: .6
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
            text: userWon ? i18n.tr("You won this round") : i18n.tr("You lost this round")
        }

        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: "#FFF"
            fontSize: "large"
            objectName: "continue"
            text: i18n.tr("Tap to continue")
        }
    }

    MouseArea {
        anchors {
            fill: parent
        }
        onClicked: close()
    }
}
