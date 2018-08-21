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


PhysicsEntity {
    id: entity
    angularDamping: 0.5
    bodyType: Body.Dynamic
    sleepingAllowed: false
    linearDamping: 0.5

    property string color: fill.color
    property alias radius: circle.radius

    signal contact(var other)

    fixtures: [
        Circle {
            id: circle
            density: 1.0
            friction: 1.0
            radius: units.gu(2)
            restitution: 0.8

            onBeginContact: contact(other.getBody().target)
        }
    ]

    Rectangle {
        id: fill
        color: "#000"
        height: target.radius * 2
        radius: width
        width: target.radius * 2
    }
}
