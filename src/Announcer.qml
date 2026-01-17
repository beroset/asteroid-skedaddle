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
import org.asteroid.voice 1.0

Item {
    Voice {
        id: voce
    }

    function speak(message) {
        console.log("SAYING:", message)
        console.log("ANNOUNCE VALUE:",announce.value)
        voce.say(message)
    }

    Component.onCompleted: {
        console.log("Voice version is " + voce.libVersion)
        var lang = Qt.locale().name
        console.log("Setting voice to " + lang);
        voce.setProperties(lang, 2, 3);
    }

    function speakRunUpdate(isFullDistance) {
        var mileDistance = Math.floor(2 * rundata.nextHalfMile * rundata.kmToMiles) / 2;
        console.log("distance:",mileDistance,"mi");
        console.log("distance:",rundata.km,"km");
        //: Spoken word for distance
        //% "Distance:"
        var speakmsg = [ qsTrId("id-distance") ]
        if (!isFullDistance) {
            if (distanceUnit.value) {
                //: fractional distance in miles
                //% "%1 miles"
                speakmsg.push(qsTrId("id-frac-miles").arg(Number(mileDistance).toLocaleString(Qt.locale())))
            } else {
                //: fractional distance in km
                //% "%1 kilometers"
                speakmsg.push(qsTrId("id-frac-distance").arg(Number(rundata.nextHalfKm).toLocaleString(Qt.locale())))
            }
        } else {
            if (distanceUnit.value) {
                //: integer distance in km
                //% "%n mile(s)"
                speakmsg.push(qsTrId("id-int-miles", parseInt(mileDistance)))
            } else {
                //: integer distance in km
                //% "%n kilometer(s)"
                speakmsg.push(qsTrId("id-int-distance", parseInt(rundata.nextHalfKm)))
            }
        }
        speakmsg.push(";")  // pause between spoken measurements
        //: Spoken word for an elapsed time
        //% "Time:"
        speakmsg.push(qsTrId("id-time"))
        var [hours, minutes, seconds, tenths] = extractUnits(rundata.elapsed);
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
        /*
         * Now calculate the pace
         */
        speakmsg.push(";")  // pause between spoken measurements
        if (!isFullDistance) {
            //: Spoken split pace
            //% "split pace"
            //~ For half km or half mile
            speakmsg.push(qsTrId("id-split-pace"))
            var [phours, pminutes, pseconds, ptenths] = extractUnits(2 * (rundata.elapsed - (distanceUnit.value ? rundata.lastHalfMileTime : rundata.lastHalfKmTime)));
        } else {
            //: Spoken pace
            //% "pace"
            speakmsg.push(qsTrId("id-pace"))
            var [phours, pminutes, pseconds, ptenths] = extractUnits(rundata.elapsed - (distanceUnit.value ? rundata.lastFullMileTime : rundata.lastFullKmTime));
        }
        if (hours > 0) {
            //: Spoken elapsed hour(s)
            //% "%n hour(s)"
            speakmsg.push(qsTrId("id-hours", parseInt(phours)))
        }
        if (minutes > 0) {
            //: Spoken elapsed minute(s)
            //% "%n minute(s)"
            speakmsg.push(qsTrId("id-minutes", parseInt(pminutes)))
        }
        //: Spoken elapsed seconds(s)
        //% "%n second(s)"
        speakmsg.push(qsTrId("id-second", parseInt(pseconds)))
        announcer.speak(speakmsg.join(" "));
    }
}
