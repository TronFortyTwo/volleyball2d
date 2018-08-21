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


#include "fullscreen.h"

#include <QDebug>
#include <QQuickView>

Fullscreen::Fullscreen(QObject *parent) :
    QObject(parent)
{
}

void Fullscreen::setFullscreen(bool state)
{
    qDebug() << "setFullscreen" << state;

    if (state) {
        m_view->showFullScreen();
    } else {
        m_view->showNormal();
    }

    emit fullscreenChanged(state);
}

void Fullscreen::setView(QQuickView *newView)
{
    this->m_view = newView;

    emit viewChanged(newView);
}
