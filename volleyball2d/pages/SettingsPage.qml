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
    id: settingsPage
    header: PageHeader {
        title: i18n.tr("Settings")
    }


    // Hack for autopilot otherwise SettingsPage appears as Page11
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
        contentHeight: settingsColumn.childrenRect.height
        objectName: "settingsFlickable"

        Column {
            id: settingsColumn
            anchors {
                fill: parent
            }

            ListItem {
                height: layoutControls.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutControls
                    title {
                        font {
                            bold: true
                        }
                        text: i18n.tr("Controls")
                    }
                }
            }

            ListItem {
                height: layoutUseMotion.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutUseMotion
                    title {
                       text: i18n.tr("Use motion")
                    }

                    CheckBox {
                        checked: settings.useMotion
                        objectName: "motionCheckBox"
                        onClicked: settings.useMotion = !settings.useMotion

                        SlotsLayout.position: SlotsLayout.Trailing
                    }
                }
            }

            ListItem {
                enabled: settings.useMotion
                objectName: "motionDeadZoneListItem"
                height: layoutMotionDeadzone.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutMotionDeadzone
                    title {
                       text: i18n.tr("Motion deadzone")
                    }

                    Slider {
                       live: true
                       minimumValue: 0
                       maximumValue: 5
                       objectName: "motionDeadZoneSlider"
                       stepSize: 1.0
                       value: settings.motionDeadZone
                       width: settingsPage.width / 3

                       SlotsLayout.position: SlotsLayout.Trailing

                       onValueChanged: settings.motionDeadZone = value
                    }

                    // FIXME: Hack to disable clipping Item parent of layout
                    Component.onCompleted: parent.clip = false
                }
            }

            ListItem {
                enabled: settings.useMotion
                objectName: "motionSensitivityListItem"
                height: layoutMotionSensitivity.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutMotionSensitivity
                    title {
                       text: i18n.tr("Motion sensitivity")
                    }

                    Slider {
                        live: true
                        function formatValue(v) { return v.toFixed(2) }
                        minimumValue: 0.5
                        maximumValue: 1.0
                        objectName: "motionSensitivitySlider"
                        value: settings.motionSensitivity
                        width: settingsPage.width / 3

                        SlotsLayout.position: SlotsLayout.Trailing

                        onValueChanged: settings.motionSensitivity = value
                    }

                    // FIXME: Hack to disable clipping Item parent of layout
                    Component.onCompleted: parent.clip = false
                }
            }

            ListItem {
                height: layoutGame.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutGame
                    title {
                        font {
                            bold: true
                        }
                        text: i18n.tr("Game")
                    }
                }
            }

            ListItem {
                height: layoutFullscreen.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutFullscreen
                    title {
                       text: i18n.tr("Fullscreen")
                    }

                    CheckBox {
                        checked: settings.fullscreen
                        objectName: "fullscreenCheckBox"

                        SlotsLayout.position: SlotsLayout.Trailing

                        onClicked: settings.fullscreen = !settings.fullscreen
                    }
                }
            }

            ListItem {
                height: layoutDebug.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutDebug
                    title {
                        font {
                            bold: true
                        }
                        text: i18n.tr("Debug")
                    }
                }
            }

            ListItem {
                height: layoutAIDebugLayer.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutAIDebugLayer
                    title {
                       text: i18n.tr("AI Debug Layer")
                    }

                    CheckBox {
                        checked: settings.aiDebugLayer
                        objectName: "aiDebugCheckBox"

                        SlotsLayout.position: SlotsLayout.Trailing

                        onClicked: settings.aiDebugLayer = !settings.aiDebugLayer
                    }
                }
            }

            ListItem {
                height: layoutReset.height + (divider.visible ? divider.height : 0)

                ListItemLayout {
                    id: layoutReset

                    Button {
                        anchors {
                            centerIn: parent
                        }
                        text: i18n.tr("Reset")

                        SlotsLayout.position: SlotsLayout.Center

                        onClicked: {  // TODO: add autopilot tests
                            settings.useMotion = true
                            settings.motionDeadZone = 3
                            settings.motionSensitivity = 0.75
                            settings.fullscreen = true
                            settings.aiDebugLayer = false

                            mainPageStack.pop()  // return back to the menu
                        }
                    }
                }
            }
        }
    }
}
