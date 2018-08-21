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

import Ubuntu.Components 1.3
import QtQuick 2.3
import "../components"


ScalePage {
    header: PageHeader {
        visible: false
    }
    objectName: "finishPage"

    property int computerScore: 0
    property int humanScore: 0
    property bool newHighScore: false
    property int time: 0
    property bool timeBased: false

    MouseArea {
        id: finishedMouseArea
        anchors {
            fill: parent
        }
        onClicked: {
            mainPageStack.pop()
            mainPageStack.pop()
        }

        Rectangle {
            anchors {
                fill: parent
            }
            color: "#000"
            opacity: .2
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
                fontSize: "x-large"
                text: timeBased ? i18n.tr("New fastest time") + ": " + time : i18n.tr("New highest score") + ": " + humanScore
                visible: newHighScore
            }

            Label {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                fontSize: "x-large"
                text: i18n.tr("Final Score")
            }

            Label {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                fontSize: "large"
                text: i18n.tr("You") + ": " + humanScore +
                      (timeBased ? " " + i18n.tr("Computer") + ": " + computerScore + " " + i18n.tr("Time") + ": " + time : "")
            }

            Label {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                text: i18n.tr("Tap to return to the menu")
            }
        }
    }
}
