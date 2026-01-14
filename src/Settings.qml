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

Flickable{
    id: settingsflick
    contentHeight: contentcolumn.implicitHeight
    Column {
        id: contentcolumn
        anchors.fill: parent
        Item {
            height: parent.width*0.15
            width: height
        }
        RowLayout {
            ColumnLayout {
                Layout.preferredWidth: contentcolumn.width / 2
                Label {
                    //: Speech settings title
                    //% "Speech"
                    text: "Notification"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width
                }
                CircularSpinner {
                    Layout.preferredHeight: settingsflick.height*0.35
                    Layout.preferredWidth: parent.width
                    Layout.alignment: Qt.AlignCenter
                    model: 3
                    delegate: 
                    SpinnerDelegate {
                        id: notify
                        text: [ "off", "half", "full" ][index]
                    }
                    Component.onCompleted: {
                        currentIndex = announce.value
                    }
                    Component.onDestruction: {
                        announce.value = currentIndex
                    }
                }
            }
            ColumnLayout {
                Layout.preferredWidth: contentcolumn.width / 2
                Label {
                    //: Unit settings title
                    //% "Unit"
                    text: "Unit"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width
                }
                CircularSpinner {
                    Layout.preferredHeight: settingsflick.height*0.35
                    Layout.preferredWidth: parent.width
                    Layout.alignment: Qt.AlignCenter
                    model: 2
                    delegate: 
                    SpinnerDelegate {
                        id: unit
                        text: [ "km", "mi" ][index]
                    }
                    Component.onCompleted: {
                        currentIndex = distanceUnit.value

                    }
                    Component.onDestruction: {
                        distanceUnit.value = currentIndex > 1 ? distanceUnit.defaultValue : currentIndex
                    }
                }
            }
        }
        Item {
            id: bottomSpacer
            height: parent.width*0.15
            width: height
        }
    }
}
