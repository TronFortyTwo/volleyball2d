TEMPLATE = app
TARGET = volleyball2d

QT += qml quick

SOURCES += main.cpp \
    fullscreen.cpp

RESOURCES += volleyball2d.qrc

OTHER_FILES += volleyball2d.apparmor \
               volleyball2d.desktop \
               volleyball2d.svg \

TRANSLATIONS += ../po/*.pot \
    ../po/*.po

#specify where the config files are installed to
config_files.path = /volleyball2d
config_files.files += $${OTHER_FILES}
message($$config_files.files)
INSTALLS+=config_files

translations.path = /po
translations.files += $${TRANSLATIONS}
message($$translations.files)
INSTALLS += translations

# Default rules for deployment.
include(../deployment.pri)

HEADERS += \
    fullscreen.h

