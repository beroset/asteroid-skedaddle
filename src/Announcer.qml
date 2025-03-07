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
import org.asteroid.voice 1.0

Item {
    //: Spoken word for distance
    //% "Distance:"
    readonly property string distanceString: qsTrId("id-distance")
    Voice {
        id: voce
    }

    function speak(message) {
        console.log("SAYING:", message)
        if (announce.value > 0) {
            voce.say(message)
        }
    }
    Component.onCompleted: {
        console.log("Voice version is " + voce.libVersion)
        var lang = Qt.locale().name
        console.log("Setting voice to " + lang);
        voce.setProperties(lang, 2, 3);
    }
    function speakRunUpdate() {
            const pace = ""
            var speakmsg = [ distanceString ]
            if (half) {
                //: fractional distance
                //% "%1 kilometers"
                speakmsg.push(qsTrId("id-frac-distance").arg(Number(nextSpokenUpdate).toLocaleString(Qt.locale())))
            } else {
                //: integer distance
                //% "%n kilometer(s)"
                speakmsg.push(qsTrId("id-int-distance", parseInt(nextSpokenUpdate)))
            }
            //: Spoken word for an elapsed time
            //% "Time:"
            speakmsg.push(qsTrId("id-time"))
            const [hours, minutes, seconds, tenths] = extractUnits(elapsed);
            if (hours > 0) {
                //: Spoken elapsed hour(s)
                //% "%n hour(s)"
                speakmsg.push(qsTrId("id-hours", parseInt(hours)))
            }
            if (minutes > 0) {
                //: Spoken elapsed minute(s)
                //% "%n minute(s)"
                speakmsg.push(qsTrId("id-minutes", parseInt(minutes)))
            }
            //: Spoken elapsed seconds(s)
            //% "%n second(s)"
            speakmsg.push(qsTrId("id-second", parseInt(seconds)))
            announcer.speak(speakmsg.join(" "));

            nextSpokenUpdate += 0.5
            half = !half
        }
}
