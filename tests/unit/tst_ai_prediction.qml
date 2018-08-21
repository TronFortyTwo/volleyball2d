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

/*
  // uncomment for debugging
import QtQuick.Window 2.1

Window {
    id: window
    height: units.gu(40)
    visible: true
    width: units.gu(70)
*/
Game {
    id: game
    currentScene: gameScene
    /*
     * Basic game scene with a ball, ground and AI
     */
    Scene {
        id: gameScene
        height: units.gu(40)
        gravity: Qt.point(0, 20)
        pixelsPerMeter: units.gu(3)
        physics: true
        width: units.gu(70)
        visible: true
        x: 0
        y: 0

        property int netDepth: units.gu(1)
        property int wallDepth: units.gu(.5)

        property Wall centreNet: net.centre
        property Wall ground: boundary.ground

        property Character lastWinner

        Item {
            id: settings
            property bool aiDebugLayer: true
            property int gameMode: computer.modeFirstToX
            property int targetScore: 5
        }

        // Level boundaries
        Boundaries {
            id: boundary
            wallDepth: parent.wallDepth
        }

        // Net in centre
        Net {
            id: net
            netDepth: parent.netDepth
        }

        Ball {
            id: volleyball
            x: gameScene.width / 2
            y: gameScene.height / 2

            property var collidedWith

            onContact: collidedWith = other
        }

        Human {
            id: human
            objectName: "human"
            x: -human.radius * 2  // human is invisible
            y: gameScene.height - human.radius

            property Wall ground: parent.ground
        }

        Computer {
            id: computer
            ball: volleyball
            enemy: human
            gravity: gameScene.gravity
            minX: net.centre.x + net.centre.width
            maxX: gameScene.width
            objectName: "computer"
            x: gameScene.width - (gameScene.width / 4) - human.radius
            y: gameScene.height - human.radius

            property Wall ground: parent.ground
            property int modeFirstToX: 1
            property int wallDepth: parent.wallDepth
        }

        // AI Prediction DEBUG
        AIDebug {
            id: aiDebug
            property int wallDepth: parent.wallDepth
        }
    }

    TestCase {
        name: "AIPrediction"

        function init(silent) {
            if (silent === undefined) {
                silent = false
            }

            if (!silent) {
                console.debug(">> init");
            }

            // Reset ball
            volleyball.collidedWith = undefined;
            volleyball.x = gameScene.width / 2
            volleyball.y = gameScene.height / 2

            // Zero velocities
            volleyball.angularVelocity = 0.0;
            volleyball.linearVelocity = Qt.point(0, 0);
            human.linearVelocity = Qt.point(0, 0);
            computer.linearVelocity = Qt.point(0, 0);

            // Reset computer
            computer.x = gameScene.width - (gameScene.width / 4) - computer.radius;
            computer.y = gameScene.height - computer.radius;

            game.gameState = Bacon2D.Running

            if (!silent) {
                console.debug("<< init");
            }
        }

        function cleanup(silent) {
            if (silent === undefined) {
                silent = false
            }

            // Reset the ball position and any game states
            if (!silent) {
                console.debug(">> cleanup");
            }

            game.gameState = Bacon2D.Paused

            if (!silent) {
                console.debug("<< cleanup");
            }
        }

        function initTestCase() {
            console.debug(">> initTestCase");
            console.debug("<< initTestCase");
        }

        function cleanupTestCase() {
            console.debug(">> cleanupTestCase");
            console.debug("<< cleanupTestCase");
        }

        function test_ball_collides_with_ground_out_of_ai_bound() {
            volleyball.linearVelocity = Qt.point(-5, 0);

            tryCompare(volleyball, "collidedWith", boundary.ground, 2000,
                       "Ball did not collide with ground")
        }

        function test_ball_collides_with_ai() {
            volleyball.linearVelocity = Qt.point(5, 0);

            tryCompare(volleyball, "collidedWith", computer, 2000,
                       "Ball did not collide with computer")
        }

        function test_ball_collides_with_ground_in_ai_bound_concentration_040() {
            // Test that with a concentration level of 0.4 the loss rate is ~15-40%
            var wonRound = 0
            var iterations = 50

            console.debug("Running AI tests, may take a while...")

            for (var i=0; i < iterations; i++) {
                // Ensure things are reset
                cleanup(true)
                init(true)

                // Set ball velocity for this session
                volleyball.linearVelocity = Qt.point((i % 10) + 5, -(i % 20));

                // Set scores (concentration)
                computer.score = 3
                human.score = 0

                // Ensure randOffset/concentration is recalc'd
                volleyball.contact(computer)

                // Wait until the ball touches the ground
                while (volleyball.collidedWith !== boundary.ground) {
                    wait(16)
                }

                // Determine if the round was won/lost
                if (volleyball.x < gameScene.width / 2) {
                    wonRound++;
                }

                console.debug(i + 1, "of", iterations, volleyball.x < gameScene.width / 2 ? "Won" : "Lost")
            }

            console.debug("Won", wonRound, "of", iterations, "rounds")

            // Check did not win all or lose all
            compare(wonRound > 0, true, "Did not win any rounds")
            compare(wonRound < iterations, true, "Did not lose any rounds")

            // Check within bounds 15-40% loss
            var lossRate = (1 - (wonRound / iterations)) * 100
            compare(lossRate < 40 && lossRate > 15, true, "Loss rate was not between 15-40%")
        }

        function test_ball_collides_with_ground_in_ai_bound_concentration_080() {
            // Test that with a concentration level of 0.80 the loss rate is 0-15%
            var wonRound = 0
            var iterations = 100

            console.debug("Running AI tests, may take a while...")

            for (var i=0; i < iterations; i++) {
                // Ensure things are reset
                cleanup(true)
                init(true)

                // Set ball velocity for this session
                volleyball.linearVelocity = Qt.point((i % 10) + 5, -(i % 20));

                // Set scores (concentration)
                computer.score = 0
                human.score = 3

                // Ensure randOffset is recalc'd
                volleyball.contact(computer)

                // Wait until the ball touches the ground
                while (volleyball.collidedWith !== boundary.ground) {
                    wait(16)
                }

                // Determine if the round was won/lost
                if (volleyball.x < gameScene.width / 2) {
                    wonRound++;
                }

                console.debug(i + 1, "of", iterations, volleyball.x < gameScene.width / 2 ? "Won" : "Lost")
            }

            console.debug("Won", wonRound, "of", iterations, "rounds")

            // Check did not win all or lose all
            compare(wonRound > 0, true, "Did not win any rounds")
            compare(wonRound < iterations, true, "Did not lose any rounds")

            // Check within bounds 0-15% loss
            var lossRate = (1 - (wonRound / iterations)) * 100
            compare(lossRate < 15 && lossRate > 0, true, "Loss rate was not between 0-15%")
        }
    }
}

