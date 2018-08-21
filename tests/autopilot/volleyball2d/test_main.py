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


class MainViewTestCase(ClickAppTestCase):
    """Generic tests for the VolleyBall"""

    def test_app_starts_on_menu(self):
        self.assertThat(self.main_view.visible, Eventually(Equals(True)))
        self.assertThat(self.menu_page.visible, Eventually(Equals(True)))
