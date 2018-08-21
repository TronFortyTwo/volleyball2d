/*
 * Copyright (C) 2015
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

#include <QtCore/QLibrary>
#include <QDebug>
#include <QGuiApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QSettings>
#include <QQmlProperty>
#include <QQuickItem>

#include "fullscreen.h"

#define WINDOW_HEIGHT 40
#define WINDOW_WIDTH 70


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("com.ubuntu.developer.andrew-hayzen.volleyball2d");

    // Necessary for Qt.labs.settings to work
    // Ref.: https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1354321
    QCoreApplication::setOrganizationDomain(QGuiApplication::applicationName());

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (QGuiApplication::arguments().contains(QLatin1String("-testability")) ||
        qgetenv("QT_LOAD_TESTABILITY") == "1") {
        QLibrary testLib(QLatin1String("qttestability"));
        if (testLib.load()) {
            typedef void (*TasInitialize)(void);
            TasInitialize initFunction = (TasInitialize)testLib.resolve("qt_testability_init");
            if (initFunction) {
                initFunction();
            } else {
                qCritical("Library qttestability resolve failed!");
            }
        } else {
            qCritical("Library qttestability load failed!");
        }
    }

    // Get GU for application
    int gu = QProcessEnvironment::systemEnvironment().value("GRID_UNIT_PX", "8").toInt();

    if (gu <= 0) {
        gu = 8;
    }

    // Load main.qml file
    QQuickView view;
    view.setSource(QUrl(QStringLiteral("qrc:///main.qml")));
    view.setObjectName("window");
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setHeight(WINDOW_HEIGHT * gu);
    view.setWidth(WINDOW_WIDTH * gu);

    // Connect to signal MainView::fullscreen(bool) to change QQuickView fullscreen state
    Fullscreen fullscreenToggle;
    fullscreenToggle.setView(&view);

    if (view.status() == QQuickView::Ready) {
        QObject *childObject = dynamic_cast<QObject *>(view.rootObject());

        QObject::connect(childObject, SIGNAL(fullscreen(bool)), &fullscreenToggle, SLOT(setFullscreen(bool)));
    } else {
        qDebug() << "Could not open qml file";
    }

    // Load the app in windowed/fullscreen depending on settings
    QSettings settings;

    settings.beginGroup(QString("settings"));

    fullscreenToggle.setFullscreen(settings.value(QString("fullscreen"), QVariant(true)).toBool());

    settings.endGroup();

    return app.exec();
}
