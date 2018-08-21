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

"""Ubuntu Touch App autopilot tests."""

import logging
import os
import shutil

from autopilot import input, platform
from autopilot.matchers import Eventually
import fixtures
from testtools.matchers import Equals
from ubuntuuitoolkit import MainView, UbuntuUIToolkitCustomProxyObjectBase
from ubuntuuitoolkit.base import (UbuntuUIToolkitAppTestCase,
                                  get_qmlscene_launch_command)

logger = logging.getLogger(__name__)


def click_object(func):
    """Wrapper which clicks the returned object"""
    def func_wrapper(self, *args, **kwargs):
        return self.pointing_device.click_object(func(self, *args, **kwargs))

    return func_wrapper


def _get_module_include_path():
    return os.path.join(get_path_to_source_root(), 'modules')


def get_path_to_source_root():
    return os.path.abspath(
        os.path.join(
            os.path.dirname(__file__), '..', '..', '..'))


def scroll_to(position):
    """Decorator to scroll to the given position within get_flickable()"""
    def decorate(func):
        def func_wrapper(self, *args, **kwargs):
            helper_scroll(self.pointing_device, self.get_flickable(), position)

            return func(self, *args, **kwargs)

        return func_wrapper

    return decorate


def helper_scroll(pointer, flickable, position):
    """Helper to scroll to a position within a flickable"""

    diff = position - flickable.contentY

    if (abs(diff) < 10 or (flickable.contentY < 0 and position == 0) or
        (flickable.contentY > flickable.contentHeight - flickable.height and
         position > flickable.contentHeight - flickable.height)):
        return

    x, y = flickable.globalRect[:2]
    x += flickable.width / 2
    y += flickable.height / 2

    pointer.move(x, y)
    pointer.drag(x, y, x, y - diff)

    flickable.flicking.wait_for(False)


class ClickAppTestCase(UbuntuUIToolkitAppTestCase):
    """Common test case that provides several useful methods for the tests."""

    package_id = 'com.ubuntu.developer.andrew-hayzen'
    app_name = 'volleyball2d'
    config_path = (os.environ["HOME"] +
                   "/.config/com.ubuntu.developer.andrew-hayzen.volleyball2d")

    def setUp(self):
        super(ClickAppTestCase, self).setUp()
        self.pointing_device = input.Pointer(self.input_device_class.create())

        self.home_dir = self._patch_home()

        self.launch_application()

        self.assertThat(self.main_view.visible, Eventually(Equals(True)))

    def launch_application(self):
        if platform.model() == 'Desktop':
            self._launch_application_from_desktop()
        else:
            self._launch_application_from_phablet()

    def _copy_xauthority_file(self, directory):
        """Copy .Xauthority file to directory, if it exists in /home"""
        # If running under xvfb, as jenkins does,
        # xsession will fail to start without xauthority file
        # Thus if the Xauthority file is in the home directory
        # make sure we copy it to our temp home directory

        xauth = os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority'))
        if os.path.isfile(xauth):
            logger.debug("Copying .Xauthority to %s" % directory)
            shutil.copyfile(
                os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority')),
                os.path.join(directory, '.Xauthority'))

    def _launch_application_from_desktop(self):
        app_qml_source_location = self._get_app_qml_source_path()
        if os.path.exists(app_qml_source_location):
            self.app = self.launch_test_application(
                        "../../volleyball2d/volleyball2d",
                        app_type='qt',
                        emulator_base=UbuntuUIToolkitCustomProxyObjectBase)
        else:
            raise NotImplementedError(
                "On desktop we can't install click packages yet, so we can "
                "only run from source.")

    def _get_app_qml_source_path(self):
        qml_file_name = 'volleyball2d/main.qml'
        return os.path.join(self._get_path_to_app_source(), qml_file_name)

    def _get_path_to_app_source(self):
        # return os.path.join(get_path_to_source_root(), self.app_name)
        return get_path_to_source_root()

    def _launch_application_from_phablet(self):
        # On phablet, we only run the tests against the installed click
        # package.
        self.app = self.launch_click_package(self.package_id, self.app_name)

    def _patch_home(self):
        """mock /home for testing purposes to preserve user data"""

        tmp_dir_fixture = fixtures.TempDir()
        self.useFixture(tmp_dir_fixture)
        tmp_dir = tmp_dir_fixture.path

        # before we set fixture, copy xauthority if needed
        self._copy_xauthority_file(tmp_dir)
        self.useFixture(fixtures.EnvironmentVariable('HOME', newvalue=tmp_dir))

        logger.debug("Patched home to fake home directory %s" % tmp_dir)

        return tmp_dir

    @property
    def game_scene(self):
        return self.app.wait_select_single(GameScene, objectName="gameScene")

    @property
    def high_score(self):
        return self.app.wait_select_single(HighScorePage,
                                           objectName="highScorePage",
                                           visible=True)

    @property
    def main_view(self):
        return self.app.wait_select_single(MainView)

    @property
    def menu_page(self):
        return self.app.select_single(MenuPage, objectName="menuPage")

    @property
    def settings(self):
        return self.app.wait_select_single(SettingsPage,
                                           objectName="settingsPage",
                                           visible=True)

    @property
    def window(self):
        return self.app.select_single(QQuickView, objectName="window")


class GameScene(UbuntuUIToolkitCustomProxyObjectBase):
    def __init__(self, *args):
        super(GameScene, self).__init__(*args)

        self.main_view = self.get_root_instance().select_single(MainView)

    @click_object
    def click_pause_button(self):
        self.point_overlay.visible.wait_for(True)
        self.point_overlay.click_continue()
        self.point_overlay.visible.wait_for(False)

        return self.get_pause_button()

    @property
    def computer(self):
        return self.select_single("Computer", objectName="computer")

    def get_pause_button(self):
        return self.select_single("Label", objectName="pauseLabel")

    @property
    def human(self):
        return self.select_single("Human", objectName="human")

    @property
    def pause_overlay(self):
        return self.main_view.wait_select_single(PauseOverlay,
                                                 objectName="pauseOverlay")

    @property
    def point_overlay(self):
        return self.main_view.wait_select_single(PointOverlay,
                                                 objectName="pointOverlay")


class HighScorePage(UbuntuUIToolkitCustomProxyObjectBase):
    def __init__(self, *args):
        super(HighScorePage, self).__init__(*args)

    def get_first_to_x_list_item(self):
        return self.select_single("SingleValue", objectName="firstToXScore")

    def get_first_to_x_value(self):
        return self.get_first_to_x_list_item().text

    def get_highest_score_list_item(self):
        return self.select_single("SingleValue", objectName="highestScore")

    def get_highest_score_value(self):
        return self.get_highest_score_list_item().text

    def get_survival_list_item(self):
        return self.select_single("SingleValue", objectName="survivalScore")

    def get_survival_value(self):
        return self.get_survival_list_item().text


class MainView(MainView):
    """Autopilot custom proxy object for the MainView."""
    def __init__(self, *args):
        super(MainView, self).__init__(*args)


class ScalePage(UbuntuUIToolkitCustomProxyObjectBase):
    def __init__(self, *args):
        super(ScalePage, self).__init__(*args)


class MenuPage(ScalePage):
    def __init__(self, *args):
        super(MenuPage, self).__init__(*args)

    @click_object
    def click_high_score_button(self):
        return self.get_high_score_button()

    @click_object
    def click_play_button(self):
        return self.get_play_button()

    @click_object
    def click_settings_button(self):
        return self.get_settings_button()

    def get_high_score_button(self):
        return self.select_single("Button", objectName="highScoreButton")

    def get_instruction_label(self):
        return self.select_single("Label", objectName="instructionLabel")

    def get_main_label(self):
        return self.select_single("Label", objectName="mainLabel")

    def get_mode_repeater(self):
        return self.select_single("QQuickRepeater", objectName="modeRepeater")

    def get_mode_repeater_value(self):
        return self.get_mode_repeater().selectedIndex

    def get_play_button(self):
        return self.select_single("Button", objectName="playButton")

    def get_settings_button(self):
        return self.select_single("Button", objectName="settingsButton")


class PauseOverlay(UbuntuUIToolkitCustomProxyObjectBase):
    def __init__(self, *args):
        super(PauseOverlay, self).__init__(*args)

    @click_object
    def click_return_to_menu_button(self):
        return self.get_return_to_menu_button()

    @click_object
    def click_continue_button(self):
        return self.get_continue_button()

    def get_return_to_menu_button(self):
        return self.select_single("Button", objectName="returnToMenu")

    def get_continue_button(self):
        return self.select_single("Button", objectName="continue")


class PointOverlay(UbuntuUIToolkitCustomProxyObjectBase):
    def __init__(self, *args):
        super(PointOverlay, self).__init__(*args)

    @click_object
    def click_continue(self):
        return self.get_continue_label()

    def get_continue_label(self):
        return self.select_single("Label", objectName="continue")


class SettingsPage(UbuntuUIToolkitCustomProxyObjectBase):
    def __init__(self, *args):
        super(SettingsPage, self).__init__(*args)

    @click_object
    def click_fullscreen_switch(self):
        return self.get_fullscreen_switch()

    @click_object
    def click_motion_switch(self):
        return self.get_motion_switch()

    @scroll_to(200)
    def get_ai_debug_checkbox(self):
        return self.select_single("CheckBox", objectName="aiDebugCheckBox")

    def get_ai_debug_state(self):
        return self.get_ai_debug_checkbox().checked

    def get_flickable(self):
        return self.select_single("QQuickFlickable",
                                  objectName="settingsFlickable")

    @scroll_to(100)
    def get_fullscreen_switch(self):
        return self.select_single("CheckBox", objectName="fullscreenCheckBox")

    def get_fullscreen_switch_state(self):
        return self.get_fullscreen_switch().checked

    @scroll_to(0)
    def get_motion_deadzone_listitem(self):
        return self.select_single("Standard",
                                  objectName="motionDeadZoneListItem")

    @scroll_to(0)
    def get_motion_deadzone_slider(self):
        return self.select_single("Slider", objectName="motionDeadZoneSlider")

    def get_motion_deadzone_value(self):
        return self.get_motion_deadzone_slider().value

    @scroll_to(0)
    def get_motion_sensitivity_listitem(self):
        return self.select_single("Standard",
                                  objectName="motionSensitivityListItem")

    @scroll_to(0)
    def get_motion_sensitivity_slider(self):
        return self.select_single("Slider",
                                  objectName="motionSensitivitySlider")

    def get_motion_sensitivity_value(self):
        return self.get_motion_sensitivity_slider().value

    @scroll_to(0)
    def get_motion_switch(self):
        return self.select_single("CheckBox", objectName="motionCheckBox")

    def get_motion_switch_state(self):
        return self.get_motion_switch().checked

    def set_fullscreen_switch_state(self, state):
        if self.get_fullscreen_switch_state() != state:
            self.click_fullscreen_switch()

    def set_motion_switch_state(self, state):
        if self.get_motion_switch_state() != state:
            self.click_motion_switch()


class QQuickView(UbuntuUIToolkitCustomProxyObjectBase):
    def __init__(self, *args):
        super(QQuickView, self).__init__(*args)

    def is_fullscreen(self):
        return self.visibility == 5
