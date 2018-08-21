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
import Bacon2D 1.0


SemiCircleEntity {
    // Entity settings
    bodyType: Body.Dynamic
    fixedRotation: true
    gravityScale: 1.5
    linearDamping: 0.8
    sleepingAllowed: false
    x: 0
    y: 0

    // Polygon settings
    categories: Fixture.Category2  // collide with the invisible character barrier
    density: 1.0
    friction: 1.0

    property bool canJump: true
    property int center: x + radius
    property int scalarLimit: 2
    property int score: 0

    onBeginContact: {
        if (other === ground) {
            canJump = true
        }
    }
    onEndContact: {
        if (other === ground) {
            canJump = false
        }
    }

    function jump() {
        // Check not currently jumping
        if (Math.abs(linearVelocity.y) < 0.01 && canJump) {
            linearVelocity = Qt.point(linearVelocity.x, -25);
        }
    }

    function left(scalar) {
        if (scalar === undefined) {  // scale defaults to 1
            scalar = 1
        }

        linearVelocity = Qt.point(-7 * scalar, linearVelocity.y);
    }

    function right(scalar) {
        if (scalar === undefined) {  // scale defaults to 1
            scalar = 1
        }

        linearVelocity = Qt.point(7 * scalar, linearVelocity.y);
    }
}
