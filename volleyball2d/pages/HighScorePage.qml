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

Page {
    header: PageHeader {
        leadingActionBar {
            actions: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Back")

                    onTriggered: mainPageStack.pop()
                }
            ]
        }
        title: i18n.tr("High Scores")
    }

    // Hack for autopilot otherwise HighScorePage appears as Page11
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

    Flickable {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: parent.header.bottom
        }
        height: parent.height
        contentHeight: scoresColumn.childrenRect.height

        Column {
            id: scoresColumn
            anchors {
                fill: parent
            }

            ListItem {
                ListItemLayout {
                    subtitle {
                        objectName: "firstToXScore"
                        text: settings.firstToXScore < 0 ? i18n.tr("N/A") : settings.firstToXScore + " " + i18n.tr("seconds")
                    }
                    title {
                        text: i18n.tr("First to") + " " + settings.targetScore
                    }
                }
            }

            ListItem {
                ListItemLayout {
                    subtitle {
                        objectName: "highestScore"
                        text: settings.highestScore < 0 ? i18n.tr("N/A") : settings.highestScore + " " + i18n.tr("points") || i18n.tr("N/A")
                    }
                    title {
                        text: i18n.tr("Highest Score")
                    }
                }
            }

            ListItem {
                ListItemLayout {
                    subtitle {
                        objectName: "survivalScore"
                        text: settings.survivalScore < 0 ? i18n.tr("N/A") : settings.survivalScore + " " + i18n.tr("points") || i18n.tr("N/A")
                    }
                    title {
                        text: i18n.tr("Survival")
                    }
                }
            }

            ListItem {
                divider {
                    visible: false
                }

                ListItemLayout {
                    Button {
                        anchors {
                            centerIn: parent
                        }
                        SlotsLayout.position: SlotsLayout.Center
                        text: i18n.tr("Reset")

                        onClicked: {  // TODO: add autopilot tests
                            settings.firstToXScore = -1
                            settings.highestScore = -1
                            settings.survivalScore = -1
                        }
                    }
                }
            }
        }
    }
}
