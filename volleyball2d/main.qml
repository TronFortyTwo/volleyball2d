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
import Qt.labs.settings 1.0

MainView {
    id: mainView
    anchors {
        fill: parent
    }
    applicationName: "com.ubuntu.developer.andrew-hayzen.volleyball2d"
    automaticOrientation: true
    objectName: "mainView"

    height: units.gu(40)
    //objectName: "window"
    //visibility: settings !== undefined && !settings.fullscreen ? Window.Windowed : Window.FullScreen
    width: units.gu(70)

    signal fullscreen(bool state)

    Settings {
        id: settings
        category: "settings"

        property bool aiDebugLayer: false
        property int gameMode: 0
        property int firstToXScore: -1
        property bool fullscreen: true
        property int highestScore: -1
        property int highestScoreTime: 120
        property int motionDeadZone: 3
        property double motionSensitivity: 0.75
        property int survivalScore: -1
        property int targetScore: 5
        property bool useMotion: true

        // Call signal that cpp listens to
        onFullscreenChanged: mainView.fullscreen(fullscreen);
    }

    PageStack {
        id: mainPageStack

        property bool landscape: width > height

        onLandscapeChanged: {
            if (landscape && (mainPageStack.currentPage === null || (mainPageStack.currentPage !== null && mainPageStack.currentPage.objectName === "rotateScreenPage"))) {
                if (mainPageStack.depth > 0) {
                    mainPageStack.pop()
                }

                if (mainPageStack.depth === 0) {
                    mainPageStack.pushPage("qrc:///pages/MenuPage.qml", {"objectName": "menuPage"})
                }
            } else if (!landscape && (mainPageStack.currentPage === null ||
                                      mainPageStack.currentPage.objectName !== "rotateScreenPage")) {
                mainPageStack.pushPage("qrc:///pages/RotateScreenPage.qml", {objectName: "rotateScreenPage"});
            }
        }

        function pushPage(pageUrl, properties) {
            if (properties === undefined) {
                properties = {}
            }

            var comp = Qt.createComponent(pageUrl)
            var sprite = comp.createObject(mainPageStack, properties)

            if (sprite == null) {  // Error Handling
                console.log("Error creating object");
            }

            mainPageStack.push(sprite);
        }

        Component.onCompleted: {
            if (landscape && mainPageStack.depth === 0) {
                mainPageStack.pushPage("qrc:///pages/MenuPage.qml", {"objectName": "menuPage"})
            }
        }
    }
}
