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
#ifndef GPXLOG_H
#define GPXLOG_H
#include <QObject>
#include <QString>
#include <QQmlEngine>
#include <fstream>

class GpxLog : public QObject{
    Q_OBJECT
public:
    static GpxLog *instance() {
        static GpxLog instance;
        return &instance;
    }
    Q_INVOKABLE bool logGPXsegment(const QString& datetime, double latitude, double longitude, double altitude, int satellites, int heartrate);
    Q_INVOKABLE bool logGPXwaypoint(const QString& datetime, double latitude, double longitude, double altitude, int satellites);
    Q_INVOKABLE bool open(const QString& datetime);
    Q_INVOKABLE bool close();
private:
    explicit GpxLog(QObject *parent = nullptr) : QObject(parent) {};
    ~GpxLog() = default;
    GpxLog(const GpxLog&) = delete;
    GpxLog &operator=(const GpxLog&) = delete;
    std::ofstream out;
    std::ofstream outwp;
    std::string filepath;
    std::string filepathwp;
};
#endif // GPXLOG_H
