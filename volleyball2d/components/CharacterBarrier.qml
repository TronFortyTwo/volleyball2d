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
    bodyType: Body.Static
    onHeightChanged: box.height = height
    onWidthChanged: box.width = width
    fixtures: Box {
        id: box
        collidesWith: Fixture.Category2  // collide with other objects in cat2
        friction: 0
    }

    Rectangle {
        id: rect
        color: "#555"
        height: parent.height
        opacity: .1
        width: parent.width
        x: 0
        y: 0
    }
}
