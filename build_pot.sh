#!/bin/sh

xgettext -o po/volleyball2d.emanuelesorce.pot --package-name volleyball2d --qt --c++ --add-comments=TRANSLATORS --keyword=tr `find . -type f -name "*.qml"`
