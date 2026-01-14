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


import QtQuick 2.15
import QtQuick.Layouts 1.3
import org.asteroid.controls 1.0

GridLayout {
    columns: 3

    Label {
        text: "GPS"
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }
    Label {
        text: "BPM"
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }
    Label {
        text: batteryLevel.percent + "%"
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }
    Label {
        id: satvis
        text: satsused + "/" + satsvisible
        horizontalAlignment: Text.AlignHCenter
        color: satsused == 0 ? "lightpink" : satsused > 3 ? "lightgreen" : "lightyellow"
        Layout.fillWidth: true
    }
    Label {
        text: app.bpm
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        
    }
    Label {
        text: now.toLocaleTimeString("HH:mm:ss")
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }
    /*
    Label {
        Layout.columnSpan: 3
        text: String(gpxlog.coord).split(",")[0]
        color: satused.color
    }
    Label {
        Layout.columnSpan: 3
        text: String(gpxlog.coord).split(",")[1]
        color: satused.color
    }
    */
}