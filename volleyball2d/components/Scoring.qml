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

Item {
    anchors {
        fill: parent
    }

    property Character player
    property Character opponent

    Label {
        anchors {
            left: parent.left
            margins: units.gu(2)
            top: parent.top
        }
        color: player.color
        fontSize: "x-large"
        font.bold: true
        text: player.score
        visible: settings.gameMode !== modeFirstToX
    }

    LiveScore {
        anchors {
            left: parent.left
        }
        color: player.color
        score: player.score
        visible: settings.gameMode === modeFirstToX
    }

    LiveScore {
        anchors {
            right: parent.right
        }
        color: opponent.color
        score: opponent.score
        visible: settings.gameMode === modeFirstToX
    }
}
