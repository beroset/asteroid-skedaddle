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

#include <format>
#include <fstream>
#include <string_view>
#include <string>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QIODevice>
#include <QDateTime>
#include "GpxLog.h"

Q_INVOKABLE bool GpxLog::open(const QString& datetime) 
{
    const QString dirPath = "/home/ceres/runlogs";
    if (!QDir(dirPath).exists()) {
        if (!QDir().mkdir(dirPath)) {
            qDebug() << "Failed to create directory";
        }
    }
    std::string timestamp{QDateTime::fromString(datetime, Qt::ISODate).toLocalTime().toString("yyyy-MM-dd_HH-mm-ss").toStdString()};
    std::string now{datetime.toStdString()};
    filepath = std::format("/home/ceres/runlogs/runlog_{}.gpx", timestamp);
    filepathwp = std::format("/home/ceres/runlogs/waypoints_{}.gpx", timestamp);
    static constexpr std::string_view header{R"(<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="AsteroidGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1">
  <metadata>
    <time>)"};
    static constexpr std::string_view trkopen{R"(</time>
  </metadata>
  <trk>
    <name>Run</name>
    <type>running</type>
    <trkseg>
)"};
    out.open(filepath);
    if (!out.is_open()) {
        qDebug() << "Writing file \"" << QString::fromStdString(filepath) << "\" FAILED";
        return false;
    }
    outwp.open(filepathwp);
    if (!outwp.is_open()) {
        qDebug() << "Writing file \"" << QString::fromStdString(filepathwp) << "\" FAILED";
        return false;
    }
    out << header << now << trkopen;
    return true;
}

Q_INVOKABLE bool GpxLog::logGPXsegment(const QString& datetime, double latitude, double longitude, double altitude, int satellites, int heartrate)
{
    if (!out.is_open()) {
        qDebug() << "ERROR: attempting to log GPX segment with closed file";
        return false;
    }
    const std::string now{datetime.toStdString()};

out << format(R"(      <trkpt lat="{:.5f}" lon="{:.5f}">
        <ele>{:.1f}</ele>
        <time>{}</time>
        <sat>{}</sat>
        <extensions>
          <gpxtpx:TrackPointExtension>
              <gpxtpx:hr>{}</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
)", latitude, longitude, 
    altitude, now, satellites, 
    heartrate);
    return true;
}

Q_INVOKABLE bool GpxLog::logGPXwaypoint(const QString& datetime, double latitude, double longitude, double altitude, int satellites)
{
    const std::string now{datetime.toStdString()};

outwp << format(R"(  <wpt lat="{:.5f}" lon="{:.5f}">
    <ele>{:.1f}</ele>
    <time>{}</time>
    <sat>{}</sat>
  </wpt>
)", latitude, longitude, 
    altitude, now, satellites);
    return true;
}

Q_INVOKABLE bool GpxLog::close()
{
    if (!out.is_open() || !outwp.is_open()) {
        qDebug() << "ERROR: Closing file that is already closed";
        return false;
    }

    out << "    </trkseg>\n  </trk>\n</gpx>\n";
    out.close();
    outwp.close();

    // inject waypoints to GPX runlog, delete waypoints file after
    QFile ftrk(QString::fromStdString(filepath));
    if (!ftrk.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "ERROR: Could not open track file";
        return false;
    }
    QFile fwpt(QString::fromStdString(filepathwp));
    if (!fwpt.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "ERROR: Could not open waypoint file";
        return false;
    }
    QString strtrk = ftrk.readAll();
    QString strwpt = fwpt.readAll();
    ftrk.close();
    fwpt.close();
    strtrk.replace("  <trk>", strwpt + "  <trk>");
    if(!ftrk.open(QIODevice::WriteOnly)) {
        qDebug() << "ERROR: Could not open track file for writing";
        return false;
    } else {
        ftrk.write(strtrk.toUtf8());
        ftrk.close();
    }
    QFile::remove(QString::fromStdString(filepathwp));

    return true;
}
