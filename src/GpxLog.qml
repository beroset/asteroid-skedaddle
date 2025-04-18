/*
 * Copyright (C) 2025 Ed Beroset <beroset@ieee.org>
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtPositioning 5.15
import org.asteroid.controls 1.0
import org.asteroid.filehelper 1.0

Item {
    property var text: ""
    property var coord
    property var prevcoord

    function logGPXsegment() {
        var loc = coord
        var currentTime = new Date
        var trkpt = '   <trkpt lat="%1" lon="%2">\n    <ele>%3</ele>\n    <sat>%4</sat>\n    <time>%5</time>\n   </trkpt>\n'
        text += trkpt.arg(loc.latitude.toFixed(7)).arg(loc.longitude.toFixed(7)).arg(loc.altitude.toFixed(1)).arg(satsused).arg(currentTime.toISOString())
        // console.log(trkpt.arg(loc.latitude.toFixed(7)).arg(loc.longitude.toFixed(7)).arg(loc.altitude.toFixed(1)).arg(satsused).arg(currentTime.toISOString()))
        if (prevcoord && prevcoord.isValid) {
            var delta = prevcoord.distanceTo(loc)
            rundata.km += (delta / 1000)
        }
        prevcoord = QtPositioning.coordinate(loc.latitude+0, loc.longitude+0, loc.altitude)
    }

    function openGPX() {
        var header = '<?xml version="1.0" encoding="UTF-8"?>\n<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" creator="AsteroidGPX" version="1.1" xmlns="http://www.topografix.com/GPX/1/1">\n<metadata>\n<time>%1</time>\n</metadata>\n'
        var trkopen = ' <trk>\n<name>Run</name>\n<type>running</type>\n  <trkseg>\n'
        var currentTime = new Date
        text = header.arg(currentTime.toISOString())
        text += trkopen
    }

    function closeGPX() {
        var currentTime = new Date
        var trkclose = '</trkseg>\n</trk>\n</gpx>\n'
        text += trkclose
        var filename = "/home/ceres/runlog%1.gpx".arg(currentTime.toISOString())
        FileHelper.writeFile(filename, text)
        satellite.active = false
    }

    PositionSource {
        id: satellite
        active: true
        updateInterval: 1000
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
        onPositionChanged: {
            var position = satellite.position;
            coord = position.coordinate;
            console.log("Coordinate:", coord.longitude, coord.latitude, coord.altitude);
            console.log("Validity:", position.longitudeValid, position.latitudeValid, position.altitudeValid);
        }
    }
}
