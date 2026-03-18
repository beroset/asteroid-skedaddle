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
#include "GpxLog.h"

Q_INVOKABLE bool GpxLog::open(const QString& datetime) 
{
    std::string now{datetime.toStdString()};
    const std::string filepath{std::format("/home/ceres/runlog{}.gpx", now)};
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
    if (out.is_open()) {
        out << header << now << trkopen;
        return true;
    }
    qDebug() << "Writing file \"" << QString::fromStdString(filepath) << "\" FAILED";
    return false;
}

Q_INVOKABLE bool GpxLog::logGPXsegment(const QString& datetime, double latitude, double longitude, double altitude, int satellites, int heartrate)
{
    if (!out.is_open()) {
        qDebug() << "ERROR: attempting to log GPX segment with closed file";
        return false;
    }
    const std::string now{datetime.toStdString()};

out 
    << format(R"(      <trkpt lat="{:.5f}" lon="{:.5f}">
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

Q_INVOKABLE bool GpxLog::close()
{
    if (out.is_open()) {
        out << "    </trkseg>\n  </trk>\n</gpx>\n";
        out.close();
        return true;
    } 
    qDebug() << "ERROR: Closing file that is already closed";
    return false;
}
