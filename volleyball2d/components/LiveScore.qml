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

Row {
    id: liveRow
    anchors {
        margins: units.gu(2)
        top: parent.top
    }
    spacing: units.gu(1)

    property string color
    property int score

    Repeater {
        model: settings.targetScore
        delegate: Rectangle {
            border.color: liveRow.color
            border.width: units.gu(.5)
            color: score > index ? liveRow.color : "transparent"
            height: radius
            radius: units.gu(3)
            width: radius
        }
    }
}
