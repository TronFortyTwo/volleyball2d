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

from .test_menu import (INSTRUCTION_MOTION_STR, INSTRUCTION_NO_MOTION_STR)


def switch_to_settings_page(func):
    """Wrapper which switches to the settings page"""
    def func_wrapper(self, *args, **kwargs):
        # Switch to settings page
        self.menu_page.visible.wait_for(True)
        self.menu_page.click_settings_button()
        self.settings.visible.wait_for(True)

        return func(self, *args, **kwargs)

    return func_wrapper


class SettingsTestCase(ClickAppTestCase):
    """Tests for the settings scene"""

    @switch_to_settings_page
    def test_switch_fullscreen(self):
        """Test the fullscreen switch changes the window state"""

        # Enable fullscreen
        self.settings.set_fullscreen_switch_state(True)
        self.assertThat(self.settings.get_fullscreen_switch_state(),
                        Eventually(Equals(True)))

        # Check window is fullscreen
        self.assertThat(self.window.is_fullscreen, Eventually(Equals(True)))

        # Disable fullscreen
        self.settings.set_fullscreen_switch_state(False)
        self.assertThat(self.settings.get_fullscreen_switch_state(),
                        Eventually(Equals(False)))

        # Check window is not fullscreen
        self.assertThat(self.window.is_fullscreen, Eventually(Equals(False)))

        # Enable fullscreen
        self.settings.set_fullscreen_switch_state(True)
        self.assertThat(self.settings.get_fullscreen_switch_state(),
                        Eventually(Equals(True)))

        # Check window is fullscreen
        self.assertThat(self.window.is_fullscreen, Eventually(Equals(True)))

    @switch_to_settings_page
    def test_initial_settings(self):
        """Test the initial settings are correct"""

        self.assertThat(self.settings.get_motion_switch_state(),
                        Eventually(Equals(True)))
        self.assertThat(self.settings.get_motion_deadzone_value(),
                        Eventually(Equals(3)))
        self.assertThat(self.settings.get_motion_sensitivity_value(),
                        Eventually(Equals(0.75)))
        self.assertThat(self.settings.get_fullscreen_switch_state(),
                        Eventually(Equals(True)))
        self.assertThat(self.settings.get_ai_debug_state(),
                        Eventually(Equals(False)))

    @switch_to_settings_page
    def test_switch_motion(self):
        """Test the motion switch changes and the labels on the menu"""

        # Enable motion - check the switch and labels
        self.settings.set_motion_switch_state(True)
        self.assertThat(self.settings.get_motion_switch_state(),
                        Eventually(Equals(True)))

        # Check labels on menu scene
        self.main_view.go_back()
        self.menu_page.visible.wait_for(True)

        self.assertThat(self.menu_page.get_instruction_label().text,
                        Eventually(Equals(INSTRUCTION_MOTION_STR)))

        self.menu_page.click_settings_button()
        self.settings.visible.wait_for(True)

        # Disable motion - check the switch and labels
        self.settings.set_motion_switch_state(False)
        self.assertThat(self.settings.get_motion_switch_state(),
                        Eventually(Equals(False)))

        # Check labels on menu scene
        self.main_view.go_back()
        self.menu_page.visible.wait_for(True)
        self.assertThat(self.menu_page.get_instruction_label().text,
                        Eventually(Equals(INSTRUCTION_NO_MOTION_STR)))

        self.menu_page.click_settings_button()
        self.settings.visible.wait_for(True)

        # Enable motion - check the switch and labels
        self.settings.set_motion_switch_state(True)
        self.assertThat(self.settings.get_motion_switch_state(),
                        Eventually(Equals(True)))

        # Check labels on menu scene
        self.main_view.go_back()
        self.menu_page.visible.wait_for(True)

        self.assertThat(self.menu_page.get_instruction_label().text,
                        Eventually(Equals(INSTRUCTION_MOTION_STR)))

    @switch_to_settings_page
    def test_switch_motion_disables_options(self):
        """Test the options are disabled when motion is disabled"""

        # Enable motion
        self.settings.set_motion_switch_state(True)
        self.assertThat(self.settings.get_motion_deadzone_listitem().enabled,
                        Eventually(Equals(True)))
        self.assertThat(self.settings.get_motion_sensitivity_listitem()
                        .enabled, Eventually(Equals(True)))

        # Disable motion
        self.settings.set_motion_switch_state(False)
        self.assertThat(self.settings.get_motion_deadzone_listitem().enabled,
                        Eventually(Equals(False)))
        self.assertThat(self.settings.get_motion_sensitivity_listitem()
                        .enabled, Eventually(Equals(False)))

        # Enable motion
        self.settings.set_motion_switch_state(True)
        self.assertThat(self.settings.get_motion_deadzone_listitem().enabled,
                        Eventually(Equals(True)))
        self.assertThat(self.settings.get_motion_sensitivity_listitem()
                        .enabled, Eventually(Equals(True)))
