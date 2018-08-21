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

    property alias centre: centreNet
    property int netDepth

    // Net in centre
    Wall {
        id: centreNet
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        friction: 0
        height: parent.height / 5
        width: parent.netDepth
    }

    // Top of centre net to prevent ball becoming stuck
    SemiCircleEntity {
        color: "#000"
        friction: 0
        radius: parent.netDepth / 2
        x: centreNet.x
        y: centreNet.y - radius
    }

    // Barrier to prevent player jumping net
    CharacterBarrier {
        anchors {
            bottom: parent.bottom
            horizontalCenter: centreNet.horizontalCenter
        }
        height: parent.height
        width: parent.netDepth
    }
}
