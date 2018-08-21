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


#ifndef FULLSCREEN_H
#define FULLSCREEN_H

#include <QObject>
#include <QQuickView>

class Fullscreen : public QObject
{
    Q_OBJECT
public:
    explicit Fullscreen(QObject *parent = 0);

    QQuickView *view() const { return m_view; }

public slots:
    void setFullscreen(bool state);
    void setView(QQuickView *newView);
signals:
    void fullscreenChanged(bool state);
    void viewChanged(QQuickView *newView);
private:
    QQuickView *m_view;
};

#endif // FULLSCREEN_H
