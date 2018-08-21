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
    objectName: "menuPage"

    header: PageHeader {
        visible: false
    }

    // Hack for autopilot otherwise MenuPage appears as ScalePage
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

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
        spacing: units.gu(1)

        Label {
            anchors {
                left: mainLabel.right
            }
            color: "#F00"
            fontSize: "large"
            rotation: -20
            text: i18n.tr("Beta") + "!"
        }

        Label {
            id: mainLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: "#111"
            fontSize: "x-large"
            objectName: "mainLabel"
            text: i18n.tr("Volleyball 2D")
        }

        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            spacing: units.gu(1)

            Repeater {
                id: modeRepeater
                model: [
                    i18n.tr("First to") + " " + settings.targetScore,
                    i18n.tr("Highest Score"),
                    i18n.tr("Survival")
                ]
                objectName: "modeRepeater"

                property var secondaryText: [
                    "",
                    i18n.tr("Within a certain amount of time"),
                    i18n.tr("Highest score without losing a point")
                ]
                property int selectedIndex: settings.gameMode

                delegate: Button {
                    color: selected ? UbuntuColors.darkGrey : UbuntuColors.coolGrey
                    height: units.gu(10)
                    width: selected ? units.gu(20) : units.gu(10)

                    property bool selected: index === settings.gameMode

                    onClicked: settings.gameMode = index

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    Behavior on width {
                        NumberAnimation {
                            id: delegateAnimation
                            duration: 200
                        }
                    }

                    Column {
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(1)
                            right: parent.right
                            rightMargin: units.gu(1)
                            verticalCenter: parent.verticalCenter
                        }

                        Label {
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            color: selected ? "#FFF" : UbuntuColors.darkGrey
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        Label {
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            color: "#FFF"
                            horizontalAlignment: Text.AlignHCenter
                            text: modeRepeater.secondaryText[index]
                            verticalAlignment: Text.AlignVCenter
                            opacity: visible ? 1 : 0
                            visible: selected && modeRepeater.secondaryText[index] && !delegateAnimation.running
                            wrapMode: Text.WordWrap

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }
        }

        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            fontSize: "small"
            objectName: "instructionLabel"
            text: settings.useMotion ?
                      i18n.tr("Rotate your device to move your player") + "\n"
                      + i18n.tr("Tap to jump")
                    :
                      i18n.tr("Press on the left or right of the screen to move") + "\n"
                      + i18n.tr("Tap in the center or a two finger press to jump")
        }

        Button {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            objectName: "playButton"
            text: i18n.tr("Play")

            onClicked: mainPageStack.pushPage("qrc:///pages/GamePage.qml", {"objectName": "gamePage"})
        }
    }

    Row {
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }
        spacing: units.gu(1)

        Button {
            iconName: "favorite-selected"
            objectName: "highScoreButton"
            height: units.gu(5)
            width: height
            onClicked: mainPageStack.pushPage("qrc:///pages/HighScorePage.qml", {"objectName": "highScorePage"})
        }

        Button {
            iconName: "settings"
            objectName: "settingsButton"
            height: units.gu(5)
            width: height
            onClicked: mainPageStack.pushPage("qrc:///pages/SettingsPage.qml", {"objectName": "settingsPage"})
        }
    }
}
