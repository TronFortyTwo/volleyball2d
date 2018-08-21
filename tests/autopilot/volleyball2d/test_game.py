# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014 Andrew Hayzen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""Tests for the Volleyballs"""

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from volleyball2d import ClickAppTestCase


class GameSceneTestCase(ClickAppTestCase):
    """Tests for the game scene"""

    def test_starts_after_click_from_menu(self):
        """Test the game starts after clicking the menu"""

        # Test menu is visible at start
        self.assertThat(self.menu_page.visible, Eventually(Equals(True)))

        # Click menu to start game
        self.menu_page.click_play_button()

        # Test game is visible and running
        self.assertThat(self.game_scene.visible, Eventually(Equals(True)))
        self.assertThat(self.game_scene.running, Eventually(Equals(True)))

        # Test scores of players are 0
        self.assertThat(self.game_scene.computer.score, Equals(0))
        self.assertThat(self.game_scene.human.score, Equals(0))

    def test_pause_game(self):
        """Test that the game pauses"""

        # Get to the state of the game running
        self.test_starts_after_click_from_menu()

        # Pause the game
        self.game_scene.click_pause_button()

        # Check game is paused and overlay shown
        self.assertThat(self.game_scene.running, Eventually(Equals(False)))
        self.assertThat(self.game_scene.pause_overlay.visible,
                        Eventually(Equals(True)))

    def test_pause_and_return_to_menu(self):
        """Test that selecting return to menu after pausing works"""

        # Get to the state of the game paused
        self.test_pause_game()

        # Click return to menu button
        self.game_scene.pause_overlay.click_return_to_menu_button()

        # Check that the game has stopped, game hidden and menu shown
        self.assertThat(self.game_scene.running, Eventually(Equals(False)))
        self.assertThat(self.game_scene.visible, Eventually(Equals(False)))
        self.assertThat(self.menu_page.visible, Eventually(Equals(True)))

    def test_resume_game(self):
        """Test that the game resumes after pausing"""

        # Get to the state of the game paused
        self.test_pause_game()

        # Resume the game
        self.game_scene.pause_overlay.click_continue_button()

        # Check game is running and overlay hidden
        self.assertThat(self.game_scene.running, Eventually(Equals(True)))
        self.assertThat(self.game_scene.pause_overlay.visible,
                        Eventually(Equals(False)))
