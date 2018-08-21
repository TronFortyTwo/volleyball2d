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

Item {
    property Ball ball
    property Character character
    property Character enemy
    property Character lastWinner
    property var gravity
    property int maxX
    property int minX

    property double concentration: 0.65  // level of concentration of the computer
    property int randOffset: character.radius

    Connections {
        target: ball
        onContact: {
            if (other === character) {  // recalc concentration on contact with ball
                calcConcentration()
            }

            randOffset = Math.random() * character.radius * 2 * (1 - concentration)
        }
    }

    Connections {
        target: character
        onScoreChanged: concentration = 1.0
    }

    Connections {
        target: enemy
        onScoreChanged: concentration = 1.0
    }

    // Calculate the concentration of the computer based on the scores
    function calcConcentration() {
        var factor = 5

        // Computer only has 'feelings' for firstToX game mode
        // Survival and high score have a fixed concentration of 0.7
        if (settings.gameMode === modeFirstToX) {
            // Computer becomes 'relaxed' as a lead is gained
            var diff = character.score - enemy.score

            if (diff > 0) {
                factor -= diff
            } else {
                factor += -diff
            }

            // Computer gains concentration towards the end of the match
            factor += Math.max(character.score, enemy.score) / 2

            // Computer has more focus if the last winner was the enemy
            if (lastWinner === enemy) {
                factor += 1
            }

            // Convert to value between 0-1
            factor /= settings.targetScore * 2

            if (factor < 0.4) {
                factor = 0.4
            } else if (factor > 0.80) {
                factor = 0.80
            }
        } else {
            factor = 0.65
        }

        concentration = factor
    }

    // Get the angle from two points
    function getAngle(topPoint, landPoint, pointHitBound) {
        if (pointHitBound < 0) {
            topPoint.x = 0
        } else if (pointHitBound > 0) {
            topPoint.x = maxX
        }

        return radToDeg(Math.atan((landPoint.x - topPoint.x) / (landPoint.y - topPoint.y)));
    }

    // Get the angle as a weight of a target direction
    function getAngleAsWeight(angle) {
        // -1 low on left, 0 high, 1 low on right
        return (angle > 45) - (angle < -45)
    }

    // Get the landing point of the ball
    function getLandPoint(ballPoint, ballU, topPoint, baseY) {
        var point = Qt.point(topPoint.x, baseY)

        // time until the ball touches the top of the character (baseY)
        var s = (topPoint.y - baseY) / gameScene.pixelsPerMeter

        // v^2 = u^2 + 2*a*s
        var v = Math.sqrt(Math.abs(0 + 2 * gravity.y * s))

        // s = 1/2 (u + v) * t
        // t = s / (1/2 * (u + v))
        var t = s / (0.5 * (0 + v))

        // calculate the X distance in the remaining arc
        point.x += ballU.x * t * gameScene.pixelsPerMeter;

        return point
    }

    // For a given diff scale the movement
    function getScalarForDiff(diff) {
        var maxThreshold = units.gu(10);

        return (diff > maxThreshold ? 1 : diff / maxThreshold) * character.scalarLimit
    }

    // Get the top point of the curve
    function getTopPoint(ballPoint, ballU) {
        var point = Qt.point(ballPoint.x, ballPoint.y)

        if (ballU.y > 0) {  // ball going up
            // calculate the diff to the Y top
            // s = (v^2 - u^2) / (2 * a)
            var diffY = (ballU.y * ballU.y) / (2 * gravity.y);

            point.x += ballU.x * (diffY / ballU.y) * gameScene.pixelsPerMeter;  // assumes X is const and not damping
            point.y += diffY * gameScene.pixelsPerMeter;
        }

        return point;
    }

    function getPointWithBounds(pointHitBound, point) {
        // Check not bouncing off a wall
        if (pointHitBound < 0) {
            point.x = -point.x
        } else if (pointHitBound > 0) {
            point.x = maxX - (point.x - maxX)
        }

        return point
    }

    // Get random offset depending on difficulty
    function getRandomOffset(direction) {
        return (direction < 0 ? randOffset : -randOffset)
    }

    // Get a target position inside the bounds when given a target+weight
    function getTargetWeightWithBounds(target, weight) {
        target += weight;

        if (target < minX) {
            target = minX;
        } else if (target > maxX) {
            target = maxX;
        }

        return target;
    }

    // Return whether a bound has been hit (-1 left, 0 not hit, +1 right wall)
    function hitBound(point) {
        return (point.x > maxX) - (point.x < 0)
    }

    function iter() {
        // Convert to Y=0 is baseline and Vy is positive when going up for easier calculation
        var ballWorldPoint = ball.getWorldCenter()

        var ballPoint = Qt.point(ballWorldPoint.x, (ballWorldPoint.y <= 0) ? -ballWorldPoint.y + gameScene.height : gameScene.height - ballWorldPoint.y)
        var ballU = Qt.point(ball.linearVelocity.x, -ball.linearVelocity.y)

        // Get the top, land points and the angle
        var topPoint = getTopPoint(ballPoint, ballU)
        var landPoint = getLandPoint(ballPoint, ballU, topPoint, character.radius)

        // Include bounds (eg walls) into account
        var landHitBound = hitBound(landPoint)
        var pred = getPointWithBounds(landHitBound, landPoint)

        // Calculate the landing angle for later
        var angle = getAngle(topPoint, pred, landHitBound);

        // Convert back to Y=0 top of screen
        landPoint.y = gameScene.height - landPoint.y;
        topPoint.y = gameScene.height - topPoint.y;


        // Debug UI
        aiDebug.angle = angle
        aiDebug.highest = Qt.point(0, topPoint.y)
        aiDebug.landing = Qt.point(pred.x, gameScene.height - wallDepth)

        //
        // Decide based on known information actions to perform
        //

        var target = character.center;
        var weight = 0;

        if (Math.abs(ballWorldPoint.x - character.center) < character.radius &&
                character.y + character.radius > ballWorldPoint.y &&
                character.y - ballWorldPoint.y < units.gu(10)) {
            // Ball is within the radius of the character and less that X units above the char
            if (ballWorldPoint.x >= character.center - units.gu(.5)) {
                // Ball is to the right of the center
                weight = character.radius / 2
            } else if (ballWorldPoint.x <= character + units.gu(.5)) {
                // Ball is to the left of the center
                weight = -character.radius / 2
            }

            character.jump()
        } else if (pred.x < minX && ballWorldPoint.x < minX) {
            // Ball is out of court and predicted to land there
            // Attempt to return to center-front
            target = minX + (maxX - minX) / 2;
            weight = -character.radius;
        } else if (Math.abs(pred.x - character.center) > units.gu(1)) {
            // Ball is predicted to land left or right of char (> 1GU)
            target = pred.x
            weight = (pred.x < character.center) ? -units.gu(1) : units.gu(1)
        }

        // Take angle into account
        weight += getAngleAsWeight(angle) * character.radius;

        aiDebug.target = Qt.point(target + weight, gameScene.height - wallDepth);

        // Randomly alter the weight offset (<=character.width)
        weight += getRandomOffset(angle)

        // Ensure that target is within the bounds of the player
        target = getTargetWeightWithBounds(target, weight);

        // AI DEBUG (final target position)
        aiDebug.actual = Qt.point(target, gameScene.height - wallDepth)
        aiDebug.text = concentration.toString() + "\n" + randOffset.toString()

        // Move to target position
        moveTo(target)
    }

    function moveTo(target) {
        if (Math.abs(character.center - target) > units.gu(1)) {
            if (character.center > target) {
                character.left(getScalarForDiff(character.center - target))
            } else {
                character.right(getScalarForDiff(target - character.center))
            }
        }
    }

    function radToDeg(radians) {
        return radians * (180 / Math.PI);
    }
}
