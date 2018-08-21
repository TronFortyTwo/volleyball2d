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
import QtQuick 2.3

Page {
    header: PageHeader {
        visible: false
    }
    objectName: "rotateScreenPage"

    Rectangle {
        anchors {
            fill: parent
        }
        color: "#000"
        opacity: .2
    }

    Label {
        anchors {
            centerIn: parent
        }
        fontSize: "x-large"
        text: i18n.tr("Please rotate your device")
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
