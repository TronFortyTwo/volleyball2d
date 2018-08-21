#!/bin/sh

xgettext -o po/com.ubuntu.developer.andrew-hayzen.volleyball2d.pot --package-name volleyball2d --qt --c++ --add-comments=TRANSLATORS --keyword=tr `find . -type f -name "*.qml"`
