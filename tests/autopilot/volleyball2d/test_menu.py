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

INSTRUCTION_MOTION_STR = "Rotate your device to move your player\nTap to jump"
INSTRUCTION_NO_MOTION_STR = ("Press on the left or right of the screen to "
                             "move\nTap in the center or a two finger press "
                             "to jump")


class MenuSceneTestCase(ClickAppTestCase):
    """Tests for the menu scene"""

    def test_inital_labels(self):
        """Test inital states of labels are correct"""

        self.assertThat(self.menu_page.visible, Eventually(Equals(True)))

        # Ensure labels are correct
        self.assertThat(self.menu_page.get_main_label().text,
                        Equals("Volleyball 2D"))
        self.assertThat(self.menu_page.get_play_button().text,
                        Equals("Play"))

        self.assertThat(self.menu_page.get_instruction_label().text,
                        Equals(INSTRUCTION_MOTION_STR))
        self.assertThat(self.menu_page.get_mode_repeater_value(),
                        Equals(0))
