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
import org.asteroid.controls 1.0

ColumnLayout {
    Label {
        //: Speech settings title
        //% "Speech"
        text: qsTrId("id-speech")
        horizontalAlignment: Text.AlignHCenter
        Layout.preferredWidth: parent.width
    }
    CircularSpinner {
        Layout.preferredHeight: parent.height * 0.4
        Layout.preferredWidth: parent.width
        model: 3
        delegate:
        SpinnerDelegate {
            id: miles
            text: [ "off", "half ", "" ][index] + (
index == 0 ? "" : useMiles.value ? "mile" : "kilometer")
        }
    }
    LabeledSwitch {
        Layout.preferredHeight: parent.height * 0.2
        //: Use miles instead of kilometers as unit
        //% "Use miles"
        text: qsTrId("id-use-miles")
        onCheckedChanged: {
            if (checked) {
                useMiles.value = true
            } else {
                useMiles.value = false
            }
        }
    }
}
