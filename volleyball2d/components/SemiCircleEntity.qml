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
    property alias categories: polygon.categories
    property alias color: circularRect.color
    property alias density: polygon.density
    property alias friction: polygon.friction
    property int radius: units.gu(5)

    property alias polygon: polygon

    signal beginContact(var other)
    signal endContact(var other)

    onRadiusChanged: {
        // Build nodes for a semi-circle
        var vertices = [Qt.point(0, radius), Qt.point(radius * 2, radius)]
        var nodes = 6;  // maximum of 8 nodes

        for (var i=1; i < nodes; i++) {
            vertices.push(Qt.point(radius * Math.cos((i * Math.PI) / nodes) + radius,
                                   radius - radius * Math.sin((i * Math.PI) / nodes)))
        }

        polygon.vertices = vertices;

        // redraw the rectangle as it is incorrect
        rectContainer.height = radius;
        rectContainer.width = radius * 2;
    }

    fixtures: [
        Polygon {
            id: polygon
            density: 1.0
            friction: 1.0
            vertices: []

            onBeginContact: {
                if (other !== null) {
                    entity.beginContact(other.parent)
                }
            }
            onEndContact: {
                if (other !== null) {
                    entity.endContact(other.parent)
                }
            }
        }
    ]

    Item {
        id: rectContainer
        clip: true
        height: radius
        width: radius * 2
        x: 0
        y: 0

        Rectangle {
            id: circularRect
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }
            color: "#F00"
            height: width
            radius: width * 2
        }
    }
}
