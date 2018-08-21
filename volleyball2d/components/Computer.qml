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

Character {
    id: computer
    color: "#00B"

    property alias interval: computerAITimer.interval

    property alias ball: computerAI.ball
    property alias enemy: computerAI.enemy
    property alias gravity: computerAI.gravity
    property alias minX: computerAI.minX
    property alias maxX: computerAI.maxX

    AIPrediction {
        id: computerAI
        character: parent
        lastWinner: gameScene.lastWinner
    }

    Timer {
        id: computerAITimer
        interval: 100
        repeat: true
        running: gameScene.running
        onRunningChanged: computerAI.concentration = 1.0
        onTriggered: computerAI.iter()
    }
}
