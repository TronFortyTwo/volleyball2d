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

import Bacon2D 1.0
import QtQuick 2.3
import QtTest 1.0
import Ubuntu.Components 1.1
import "../../volleyball2d/components"

// See more details @ http://doc.qt.io/qt-5/qml-qttest-testcase.html
// Ensure qml-module-qttest is installed
// Execute tests with:
//   qmltestrunner

Game {
    id: game
    currentScene: scene
    gameState: Bacon2D.Paused
    /*
     * Basic game scene with a ball in the air and ground underneath
     * If the ball collides with anything it will store that in the
     * property collidedWith
     */
    Scene {
        id: scene
        height: units.gu(20)
        gravity: Qt.point(0, 20)
        pixelsPerMeter: units.gu(3)
        physics: true
        width: units.gu(20)

        Ball {
            id: ball
            x: 5
            y: 100

            property var collidedWith

            onContact: collidedWith = other
        }

        Wall {
            id: ground
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: units.gu(1)
        }
    }

    TestCase {
        name: "GameBall"

        function init() {
            console.debug(">> init");
            compare(scene.running, false, "Scene.Running was not false");
            fuzzyCompare(ball.y, 100, 1, "ball.y was not at start position");
            console.debug("<< init");
        }

        function cleanup() {
            // Reset the ball position and any game states
            console.debug(">> cleanup");
            game.gameState = Bacon2D.Paused
            ball.y = 100
            console.debug("<< cleanup");
        }

        function initTestCase() {
            console.debug(">> initTestCase");
            console.debug("<< initTestCase");
        }

        function cleanupTestCase() {
            console.debug(">> cleanupTestCase");
            console.debug("<< cleanupTestCase");
        }

        function test_ball_collides_with_ground() {
            // When the game is running, test the ball collides with the ground
            game.gameState = Bacon2D.Running;

            tryCompare(ball, "collidedWith", ground, 2000,
                       "Ball did not collided with wall")
        }

        function test_ball_falls() {
            // When the game is running, test the ball falls
            game.gameState = Bacon2D.Running;

            wait(100);  // wait for the ball to fall

            // Need to check ball.y != 100 so expect failure
            expectFail("", "Ball.y should change (it is falling)")

            fuzzyCompare(ball.y, 100, 1, "Ball.y equals inital y")
        }

        function test_ball_stationary() {
            // When the game is not running, test the ball remains stationary

            wait(100);  // wait to check the ball doesn't fall

            // fuzzyCompare as ball.y could be 100.abc
            fuzzyCompare(ball.y, 100, 1, "Ball.y doesn't equal inital y")
        }
    }
}

