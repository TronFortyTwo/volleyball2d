/*
 * Copyright (C) 2015
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


Item {
    anchors {
        fill: parent
    }

    default property alias childrenDefault: scalable.children
    property int scalar: units.gu(70)

    Item {
        id: scalable
        height: parent.height / scale
        scale: parent.width / scalar
        transformOrigin: Qt.TopLeftCorner
        width: scalar
    }
}
