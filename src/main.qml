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
import org.asteroid.voice 1.0

Application {
    id: app

    centerColor: "#181f54"
    outerColor: "#031cfc"

    property bool isRunning: false
    property double startTime: 0
    property double km: 0
    property bool useMiles: false
    property bool half: true
    property double nextSpokenUpdate: 0.5
    property double speedup: 1.0
    property int satsvisible: 0
    property int satsused: 0
    property bool silent: true
    property date now: new Date()

    ConfigurationValue {
        id: previousTime
        key: "/skedaddle/useMiles"
        defaultValue: false
    }

    Voice {
        id: voce
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
        win: null
        firstPage: firstPageComponent
    }

    Item {
        id: gpxlog
        property var text: ""
        property date timestamp
        property var coord
        property var prevcoord

        function logGPXsegment() {
            var loc = gpxlog.coord
            var currentTime = new Date
            var trkpt = '   <trkpt lat="%1" lon="%2">\n    <ele>%3</ele>\n    <sat>%4</sat>\n    <time>%5</time>\n   </trkpt>\n'
            gpxlog.text += trkpt.arg(loc.latitude.toFixed(7)).arg(loc.longitude.toFixed(7)).arg(loc.altitude.toFixed(1)).arg(satsused).arg(currentTime.toISOString())
            console.log(trkpt.arg(loc.latitude.toFixed(7)).arg(loc.longitude.toFixed(7)).arg(loc.altitude.toFixed(1)).arg(satsused).arg(currentTime.toISOString()))
            if (prevcoord && prevcoord.isValid) {
                var delta = prevcoord.distanceTo(loc)
                km += (delta / 1000)
                console.log("coord    : " + loc);
                console.log("prevcoord: " + prevcoord);
                console.log("Delta: " + delta + ", totalKm: " + km)
            }
            gpxlog.prevcoord = QtPositioning.coordinate(loc.latitude+0, loc.longitude+0, loc.altitude)
        }

        function openGPX() {
            var header = '<?xml version="1.0" encoding="UTF-8"?>\n<gpx version="1.0" creator="AsteroidGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/0" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd">\n<metadata>\n<time>%1</time>\n</metadata>\n'
            var trkopen = ' <trk>\n<name>Afternoon Run</name>\n<type>running</type>\n'
            var currentTime = new Date
            gpxlog.text = header.arg(currentTime.toISOString())
            gpxlog.text += trkopen
        }

        function saveFile(fileUrl, text) {
            var request = new XMLHttpRequest();
            request.open("PUT", fileUrl, false);
            request.send(text);
            return request.status;
        }

        function closeGPX() {
            var currentTime = new Date
            var trkclose = '</trkseg>\n</trk>\n</gpx>\n'
            gpxlog.text += trkclose
            var filename = "file:///home/ceres/runlog%1.txt".arg(currentTime.toISOString())
            //var filename = "file:///home/ejb/tools/AsteroidOS/asteroid-runner/src/runlog%1.txt".arg(currentTime.toISOString())
            saveFile(filename, gpxlog.text)
            satellite.active = false
        }

        PositionSource {
            id: satellite
            active: true
            updateInterval: 1000
            preferredPositioningMethods: PositionSource.SatellitePositioningMethods
            onPositionChanged: {
                var position = satellite.position;
                var coord = position.coordinate;
                gpxlog.coord = coord
                console.log("Coordinate:", coord.longitude, coord.latitude, coord.altitude);
                console.log("Validity:", position.longitudeValid, position.latitudeValid, position.altitudeValid);
            }
        }
    }

    function extractUnits(milliseconds) {
        const totalSeconds = Math.floor(milliseconds / 1000);
        const tenths = Math.floor((milliseconds % 1000) / 100);
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        return [hours, minutes, seconds, tenths];
    }

    function speak(message) {
        console.log("SAYING:", message)
        if (!silent) {
            voce.say(message)
        }
    }

    function formatDistance(kilometers) {
        var dist = kilometers * (useMiles ? 0.621371 : 1)
        var distanceUnits = useMiles ? "mi" : "km"
        return `${dist.toFixed(2)} ${distanceUnits}`
    }

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

    Component {
        id: firstPageComponent

        Item {

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
                    text: "0.00 km"
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
                                console.log("Voice version is " + voce.libVersion)
                                var lang = Qt.locale().name
                                console.log("Setting voice to " + lang);
                                voce.setProperties(lang, 2, 3);
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
                        onClicked: layerStack.push(configLayer)
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
                    text: "0.0"
                }
            }

            Timer {
                id: tenthsTimer
                interval: 100
                repeat:  true
                running: isRunning
                triggeredOnStart: true

                onTriggered: updateDisplay()
            }
            function updateDisplay() {
                var elapsed = new Date().getTime() - startTime
                elapsed *= speedup;
                time.text = formatMilliseconds(elapsed);
                if (speedup > 1) {
                    km += (speedup / 2750)
                }
                distance.text = formatDistance(km)
                if (km >= nextSpokenUpdate) {
                    const pace = ""
                    //: Spoken word for distance
                    //% "Distance:"
                    var speakmsg = [ qsTrId("id-distance") ]
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
                    speak(speakmsg.join(" "));

                    nextSpokenUpdate += 0.5
                    half = !half
                }
            }
        }
    }

    Component {
        id: configLayer;
        ColumnLayout {
            Label {
                text: "Speech"
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
index == 0 ? "" : useMiles ? "mile" : "kilometer")
                }
            }
            LabeledSwitch {
                Layout.preferredHeight: parent.height * 0.2
                //: Use miles instead of kilometers as unit
                //% "Use miles"
                text: qsTrId("id-use-miles")
                onCheckedChanged: {
                    if (checked) {
                        useMiles = true
                    } else {
                        useMiles = false
                    }
                }
            }
        }
    }
    Component.onCompleted: DisplayBlanking.preventBlanking = true
}
