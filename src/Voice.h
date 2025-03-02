/*
 * Copyright (C) 2025 - Ed Beroset <beroset@ieee.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef VOICE_H
#define VOICE_H
#include <espeak/speak_lib.h>
#include <QObject>
#include <QString>
#include <QQmlEngine>

class Voice : public QObject{
    Q_OBJECT
    Q_PROPERTY(QString libVersion READ libVersion)
public:
    explicit Voice(QObject *parent = nullptr);
    ~Voice();
public slots:
    [[nodiscard]] QString libVersion() const;
    Q_INVOKABLE void setProperties(QString languages, int gender=0, int variant=0, int age=0);
    Q_INVOKABLE void say(QString message);
private:
    espeak_VOICE voice;
};
#endif // VOICE_H
