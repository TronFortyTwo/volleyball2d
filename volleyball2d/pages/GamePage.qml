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
import Ubuntu.Components 1.3
import Bacon2D 1.0

Page {
    header: PageHeader {
        visible: false
    }

    visible: true

    onVisibleChanged: {  // User rotate device so RotateScreenPage is pushed
        if (!visible && mainPageStack.currentPage.objectName === "rotateScreenPage" && gameSceneLoader.status === Loader.Ready) {
            gameSceneLoader.item.pause()
        }
    }

    Game {
        id: game
        anchors {
            left: parent.left
            top: parent.top
        }

        currentScene: gameSceneLoader.item
        height: parent.height / scale
        scale: parent.width / width  // scale the scenes to meet the width
        transformOrigin: Qt.TopLeftCorner
        width: units.gu(70)

        property bool pageLoaded: false

        // Scenes loaded once the page has loaded otherwise height is infinity
        Loader {
            id: gameSceneLoader
            active: parent.pageLoaded
            asynchronous: true
            source: "qrc:///scenes/GameScene.qml"

            onStatusChanged: {
                if (status === Loader.Ready) {
                    gameSceneLoader.item.restart()
                }
            }

            Connections {
                target: gameSceneLoader.item
                onEndGame: {
                    game.gameState = Bacon2D.Paused
                    mainPageStack.pop()
                }
                onGameFinished: {
                    var newHighScore = false;

                    if (settings.gameMode === gameSceneLoader.item.modeFirstToX) {
                        // Save new time if it is faster
                        if (human.score > computer.score &&
                                (time < settings.firstToXScore || settings.firstToXScore === -1)) {
                            settings.firstToXScore = time
                            newHighScore = true
                        } else {
                            newHighScore = false
                        }
                    } else if (settings.gameMode === gameSceneLoader.item.modeHighestScore) {
                        // Save the new highest
                        if (human.score > settings.highestScore || settings.highestScore === -1) {
                            settings.highestScore = human.score
                            newHighScore = true
                        } else {
                            newHighScore = false
                        }
                    } else if (settings.gameMode === gameSceneLoader.item.modeSurvival) {
                        // Save new longest survival
                        if (human.score > settings.survivalScore || settings.survivalScore === -1) {
                            settings.survivalScore = human.score
                            newHighScore = true
                        } else {
                            newHighScore = false
                        }
                    } else {
                        console.debug("Unknown gameMode to save!")
                    }

                    // Switch to the finish page and tell it about the scores
                    mainPageStack.push("qrc:///pages/FinishPage.qml", {
                        "objectName": "finishPage",
                        "computerScore": computer.score,
                        "humanScore": human.score,
                        "time": time,
                        "timeBased": settings.gameMode === gameSceneLoader.item.modeFirstToX,
                        "newHighScore": newHighScore
                    })

                    game.gameState = Bacon2D.Paused
                }
                onPause: {
                    // don't show pauseOverlay if pointOverlay is shown
                    if (!pointOverlayLoader.visible && pointOverlayLoader.status === Loader.Ready) {
                        pauseOverlayLoader.visible = true
                    }

                    game.gameState = Bacon2D.Paused
                }
                onResume: {
                    if (pauseOverlayLoader.status === Loader.Ready) {
                        pauseOverlayLoader.item.resume()
                    }
                }
                onRoundWon: {
                    // Increment score and store last winner
                    winner.score++;
                    gameSceneLoader.item.lastWinner = winner;

                    // Check if the game has finished
                    if (settings.gameMode === gameSceneLoader.item.modeFirstToX &&
                            winner.score >= settings.targetScore) {
                        gameSceneLoader.item.gameFinished(human, computer, time);
                    } else if (settings.gameMode === gameSceneLoader.item.modeSurvival && winner === computer) {
                        gameSceneLoader.item.gameFinished(human, computer, time);
                    } else {
                        pointOverlayLoader.visible = true;
                        pointOverlayLoader.item.userWon = winner === human;
                    }
                }
            }
        }

        Component.onCompleted: pageLoaded = true
    }

    Loader {
        id: pauseOverlayLoader
        anchors {
            fill: parent
        }
        asynchronous: true
        source: "qrc:///components/PauseOverlay.qml"
        visible: false

        Connections {
            target: pauseOverlayLoader.item
            onEndGame: gameSceneLoader.item.endGame()
            onResume: {
                pauseOverlayLoader.visible = false;
                game.gameState = Bacon2D.Running

                // Ensure focus is correct
                game.currentScene.forceActiveFocus()
            }
        }
    }

    // Point overlay at the end of a round
    Loader {
        id: pointOverlayLoader
        anchors {
            fill: parent
        }
        asynchronous: true
        source: "qrc:///components/PointOverlay.qml"
        visible: false

        onVisibleChanged: {
            if (visible) {
                game.gameState = Bacon2D.Paused
            }
        }

        Connections {
            target: pointOverlayLoader.item
            onClose: {
                pointOverlayLoader.visible = false
                gameSceneLoader.item.reset()
            }
        }
    }
}
