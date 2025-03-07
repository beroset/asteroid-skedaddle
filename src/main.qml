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
import Nemo.Configuration 1.0
import Nemo.KeepAlive 1.1
import Nemo.DBus 2.0
import org.asteroid.controls 1.0

Application {
    id: app

    centerColor: "#181f54"
    outerColor: "#031cfc"

    property bool isRunning: false
    property double startTime: 0
    property double km: 0
    property bool half: true
    property double nextSpokenUpdate: 0.5
    property double speedup: 19.0
    property int satsvisible: 0
    property int satsused: 0
    property bool silent: true
    property date now: new Date()
    property real elapsed: 0

    ConfigurationValue {
        id: useMiles
        key: "/skedaddle/useMiles"
        defaultValue: false
    }

    ConfigurationValue {
        id: announce
        key: "/skedaddle/announce"
        // values: 0 = off, 1 = half, 2 = whole
        defaultValue: 0
    }

    Timer {
        id: tenthsTimer
        interval: 100
        repeat:  true
        running: isRunning
        triggeredOnStart: true

        onTriggered: updateDisplay()
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
        elapsed = (new Date().getTime() - startTime) * speedup
        if (speedup > 1) {
            km += (speedup / 2750)
        }
        if (km >= nextSpokenUpdate) {
            announcer.speakRunUpdate()
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
