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
import QtSensors 5.11
import Nemo.Configuration 1.0
import Nemo.KeepAlive 1.1
import Nemo.DBus 2.0
import org.asteroid.controls 1.0
import Nemo.Ngf 1.0
import Nemo.Notifications 1.0

Application {
    id: app

    centerColor: "#181f54"
    outerColor: "#031cfc"

    property bool isRunning: false
    property bool isPaused: false
    property double speedup: 1.0
    property int satsvisible: 0
    property int satsused: 0
    property date now: new Date()
    property int bpm: 0

    Item {
        id: rundata
        property double startTime: 0
        property double km: 0
        property double lastHalfKmTime: 0
        property double lastHalfMileTime: 0
        property double lastFullKmTime: 0
        property double lastFullMileTime: 0
        property double nextHalfKm: 0.5
        readonly property double kmToMiles: 0.621371
        property double nextHalfMile: 0.5 / kmToMiles
        property real elapsed: 0
        property real savedTime: 0

        function reset() {
            startTime = new Date().getTime()
            km = 0
            lastHalfKmTime = 0
            lastHalfMileTime = 0
            lastFullKmTime = 0
            lastFullMileTime = 0
            nextHalfKm = 0.5
            nextHalfMile = 0.5 / kmToMiles
            savedTime = 0
        }

        function update() {
            nextHalfMile = (Math.floor(2 * km * kmToMiles) + 1) / kmToMiles / 2;
            nextHalfKm = (Math.floor(2 * km) + 1) / 2;
        }

        function pause() {
            savedTime = elapsed
        }
    }

    ConfigurationValue {
        id: distanceUnit
        key: "/skedaddle/distanceUnit"
        // values: 0 = "km", 1 = "mi"
        defaultValue: 0
    }

    ConfigurationValue {
        id: announce
        key: "/skedaddle/announce"
        // values: 0 = off, 1 = half, 2 = whole
        defaultValue: 0
    }

    ConfigurationValue {
        id: speakAnnounce
        key: "/skedaddle/speakAnnounce"
        defaultValue: false
    }

    ConfigurationValue {
        id: vibrateAnnounce
        key: "/skedaddle/vibrateAnnounce"
        defaultValue: true
    }

    Timer {
        id: tenthsTimer
        interval: 100
        repeat:  true
        running: isRunning
        triggeredOnStart: true

        onTriggered: updateDisplay()
    }

    NonGraphicalFeedback {
        id: feedback
        event: "press"
    }

    Notification {
        id: runnotification
        appName: "asteroid-skedaddle"
    }

    function extractUnits(milliseconds) {
        const totalSeconds = Math.floor(milliseconds / 1000);
        const tenths = Math.floor((milliseconds % 1000) / 100);
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        return [hours, minutes, seconds, tenths];
    }

    function updateDisplay() {
        rundata.elapsed = rundata.savedTime + (new Date().getTime() - rundata.startTime) * speedup
        const [hours, minutes, seconds, tenths] = extractUnits(Number(rundata.elapsed));
        var isFullKm = ((Math.floor(rundata.nextHalfKm*10)%10) == 0 ? true : false);
        var isFullMile = ((Math.floor((rundata.nextHalfMile*rundata.kmToMiles)*10)%10) == 0 ? true : false);

        if (speedup > 1) {
            rundata.km += (speedup / 2750)
        }
        if (rundata.km >= rundata.nextHalfMile) {
            // always update time
            rundata.lastHalfMileTime = Number(rundata.elapsed)
            if ( isFullMile ) {
                rundata.lastFullMileTime = Number(rundata.elapsed)
            }

            // only give feedback if set to miles
            if (distanceUnit.value && ((announce.value == 2 && isFullMile) || announce.value == 1)) {
                // haptic feedback
                if (vibrateAnnounce.value) {
                    feedback.play()
                }

                // graphical feedback
                var mileDistance = Math.floor(2 * rundata.nextHalfMile * rundata.kmToMiles) / 2
                runnotification.replacesId = 0
                runnotification.previewSummary = mileDistance.toString() + "mi"
                runnotification.previewBody = minutes.toString() + "m " + seconds.toString() + "s\n" + Math.floor((3600 / (Number(rundata.lastHalfMileTime)/1000)) * rundata.km*rundata.kmToMiles).toString() + "mi/h"
                runnotification.publish()
            
                // acustic feedback
                if (speakAnnounce.value) {
                    announcer.speakRunUpdate(isFullMile)
                }
            }
            rundata.update()
        }
        if (rundata.km >= rundata.nextHalfKm) {
            // always update time
            rundata.lastHalfKmTime = Number(rundata.elapsed)
            if (isFullKm) {
                rundata.lastFullKmTime = Number(rundata.elapsed)
            }

            // only give feedback if set to kilometers
            if (!distanceUnit.value && ((announce.value == 2 && isFullKm) || announce.value == 1)) {
                // haptic feedback
                if (vibrateAnnounce.value) {
                    feedback.play()
                }

                // graphical feedback
                runnotification.replacesId = 0
                runnotification.previewSummary = rundata.nextHalfKm.toString() + "km"
                runnotification.previewBody = minutes.toString() + "m " + seconds.toString() + "s\n" + Math.floor((3600 / (Number(rundata.lastHalfKmTime)/1000)) * rundata.km).toString() + "km/h"
                runnotification.publish()

                // acustic feedback
                if (speakAnnounce.value) {
                    announcer.speakRunUpdate(isFullKm)
                }
            }
            rundata.update()
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            now = new Date()
            locationDBus.update()
            if (isRunning) {
                gpxlog.logGPXsegment()
            }
        }
    }

    DBusInterface {
        id: locationDBus
        bus: DBus.SessionBus
        service: "org.freedesktop.Geoclue.Providers.Hybris"
        path: "/org/freedesktop/Geoclue/Providers/Hybris"
        iface: "org.freedesktop.Geoclue.Satellite"
        function update() {
            call("GetSatellite", undefined, function(timestamp, used, visible) {
                satsused = used
                satsvisible = visible
                console.log("used: " + used + " vis: " + visible);
            });
        }
    }

    HrmSensor {
        active: true
        onReadingChanged: {
            app.bpm = reading.bpm
        }
    }

    LayerStack {
        id: layerStack
        firstPage: firstPageComponent
    }

    GpxLog {
        id: gpxlog
    }

    Announcer {
        id: announcer
    }

    Component {
        id: firstPageComponent
        StartDisplay {}
    }

    Component {
        id: activityLayer
        RunDisplay {}
    }

    Component {
        id: configLayer;
        Settings {}
    }
    Component.onCompleted: {
        DisplayBlanking.preventBlanking = true
    }
}
