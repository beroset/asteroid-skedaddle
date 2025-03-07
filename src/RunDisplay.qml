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

Item {

    function formatMilliseconds(milliseconds) {
        const [hours, minutes, seconds, tenths] = extractUnits(milliseconds);

        const parts = [];

        if (hours > 0) {
            parts.push(hours.toString());
            parts.push(minutes.toString().padStart(2, '0'));
            parts.push(seconds.toString().padStart(2, '0') + "." + tenths);
        } else if (minutes > 0) {
            parts.push(minutes.toString())
            parts.push(seconds.toString().padStart(2, '0') + "." + tenths);
        } else {
            parts.push(seconds.toString() + "." + tenths);
        }

        return parts.join(':');
    }

    function formatDistance(kilometers) {
        var dist = kilometers * (useMiles.value ? 0.621371 : 1)
        var distanceUnits = useMiles.value ? "mi" : "km"
        return `${dist.toFixed(2)} ${distanceUnits}`
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        Label {
            id: distance
            Layout.topMargin: parent.height * 0.1
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: parent.height * 0.2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font {
                pixelSize: parent.height * 0.18
            }
            text: formatDistance(km)
        }

        RowLayout {
            width: parent.width
            IconButton {
                id: startstop
                iconName: isRunning ? "ios-pause" : "ios-play"
                onClicked: {
                    isRunning = !isRunning
                    if (isRunning) {
                        startTime = new Date().getTime()
                        km = 0
                        gpxlog.openGPX()
                    } else {
                        gpxlog.closeGPX()
                    }
                }
            }
            GridLayout {
                columns: 3
                Label { 
                    text: "sats"
                    Layout.fillWidth: true
                }
                Label {
                    text: "used"
                    Layout.fillWidth: true
                }
                Label {
                    text: ""
                }
                Label {
                    id: satvis
                    text: satsvisible
                }
                Label {
                    id: satused
                    text: satsused
                    color: satsused == 0 ? "lightpink" : satsused > 3 ? "lightgreen" : "lightyellow"
                }
                Label {
                    text: now.toLocaleTimeString("HH:mm:ss")
                }
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
            }

            IconButton {
                iconName: "ios-settings"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                onClicked: layerStack.push(configLayer,{})
            }
        }

        Label {
            id: time
            Layout.bottomMargin: parent.height * 0.1
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: parent.height * 0.2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font {
                pixelSize: parent.height * 0.18
            }
            text: formatMilliseconds(elapsed);
        }
    }
}
