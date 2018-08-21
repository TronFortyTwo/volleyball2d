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

Item {
    anchors {
        fill: parent
    }

    property alias ground: bottomWall
    property int wallDepth

    Wall {
        id: bottomWall
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: wallDepth
    }
    Wall {
        id: leftWall
        anchors {
            bottom: parent.bottom
            right: parent.left
        }
        friction: 0
        height: parent.height * 10
        width: wallDepth
    }
    Wall {
        id: rightWall
        anchors {
            bottom: parent.bottom
            left: parent.right
        }
        friction: 0
        height: parent.height * 10
        width: wallDepth
    }
}
