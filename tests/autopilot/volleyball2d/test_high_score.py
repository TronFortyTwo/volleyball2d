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


def switch_to_high_score_page(func):
    """Wrapper which switches to the settings page"""
    def func_wrapper(self, *args, **kwargs):
        # Switch to settings page
        self.menu_page.visible.wait_for(True)
        self.menu_page.click_high_score_button()
        self.high_score.visible.wait_for(True)

        return func(self, *args, **kwargs)

    return func_wrapper


class HighScoreTestCase(ClickAppTestCase):
    """Tests for the high score page"""

    @switch_to_high_score_page
    def test_initial_high_score(self):
        """Test the initial high scores are correct"""

        self.assertThat(self.high_score.get_first_to_x_value(),
                        Eventually(Equals("N/A")))
        self.assertThat(self.high_score.get_highest_score_value(),
                        Eventually(Equals("N/A")))
        self.assertThat(self.high_score.get_survival_value(),
                        Eventually(Equals("N/A")))
