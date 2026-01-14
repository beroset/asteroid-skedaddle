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
import QtPositioning 5.15
import Nemo.Mce 1.0
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
        var dist = kilometers * (distanceUnit.value ? rundata.kmToMiles : 1)
        return `${dist.toFixed(2)}`
    }

    function getDistanceUnit() {
        var distanceUnits = distanceUnit.value ? 
            //: Abbreviation for miles
            //% "mi"
            qsTrId("id-mile-abbrev") :
            //: Abbreviation for kilometers
            //% "km"
            qsTrId("id-km-abbrev")
        return `${distanceUnits}`
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // distance
        RowLayout {
            height: parent.height * 0.2
            Layout.topMargin: parent.height * 0.1
            Layout.alignment: Qt.AlignCenter
            Label {
                id: distance
                Layout.preferredHeight: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font {
                    pixelSize: parent.height
                }
                text: formatDistance(rundata.km)
            }

            Label {
                Layout.preferredHeight: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                font {
                    pixelSize: parent.height * 0.4
                }
                text: getDistanceUnit()
            }
        }

        DataGrid {
            Layout.maximumWidth: parent.width * 0.76
            Layout.alignment: Qt.AlignCenter
        }
        
        MceBatteryLevel {
            id: batteryLevel
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
            text: formatMilliseconds(rundata.elapsed);
        }
    }

    Component.onCompleted: {
        rightIndicVisible = false
    }
}
