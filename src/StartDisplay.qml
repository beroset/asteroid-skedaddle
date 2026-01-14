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
    BorderGestureArea {
        id: gestureArea
        anchors.fill: parent
        acceptsLeft: true
        acceptsUp: true
        onGestureFinished: {
            if (gesture == "left") {
                rightIndicVisible = false
                layerStack.push(activityLayer,{})
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 1

        DataGrid {
            Layout.maximumWidth: parent.width * 0.76
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: parent.height * 0.1
        }

        MceBatteryLevel {
            id: batteryLevel
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter

            Item {
                width: Dims.w(50)
                height: width

                IconButton {
                    anchors {
                        centerIn: parent
                    }
                    id: startpause
                    width: Dims.w(40)
                    height: width
                    iconName: isRunning ? "ios-pause" : "ios-play"

                    onClicked: {
                        if (!isRunning) {
                            if (!isPaused) {
                                gpxlog.openGPX()
                                rundata.reset()
                            }
                            else {
                                rundata.startTime = new Date().getTime()
                            }
                            isRunning = true
                            isPaused = false
                            layerStack.push(activityLayer,{})
                            console.log("play")
                        } else {
                            isRunning = false
                            isPaused = true
                            rundata.pause()
                            console.log("pause")
                        }
                    }
                }
            }
            Item {
                width: Dims.w(50)
                height: width
                enabled: (isRunning || isPaused) ? true : false
                opacity: (isRunning || isPaused) ? 1 : 0.4

                Canvas {
                    id: progress
                    property real degree: 0

                    anchors {
                        centerIn: parent
                        fill: parent
                    }

                    rotation: -90
                    opacity: 0.4
                    onDegreeChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        var x = parent.width / 2
                        var y = parent.height / 2
                        var startAngle = (Math.PI / 180) * 0;
                        var progressAngle = (Math.PI / 180) * degree;

                        ctx.reset()
                        ctx.beginPath()
                        ctx.lineCap = "round"
                        ctx.lineWidth = Dims.h(3)
                        ctx.strokeStyle = "#cccccc"
                        ctx.arc(x, y, (Dims.w(100) / 5), startAngle, progressAngle, false)
                        ctx.stroke()
                    }

                    // Animate progress while pressed
                    NumberAnimation on degree {
                        id: progressAnimation
                        duration: 700
                        from: 0
                        to: 360
                        easing.type: Easing.Linear
                        alwaysRunToEnd: false
                        running: false
                    }
                }
                IconButton {
                    anchors {
                        centerIn: parent
                    }

                    id: stop
                    width: Dims.w(30)
                    height: width
                    iconName: "ios-square"

                    onPressed: {
                        if (isRunning || isPaused) {
                            progressAnimation.restart();
                            progress.degree = 0
                        }
                        console.log("press")
                    }
                    onReleased: {
                        progressAnimation.stop();
                        progress.degree = 0
                        console.log("release")
                    }
                    onCanceled: {
                        progressAnimation.stop();
                        progress.degree = 0
                        console.log("cancel")
                    }
                    onPressAndHold: {
                        isRunning = false
                        isPaused = false
                        gpxlog.closeGPX()
                        layerStack.push(activityLayer,{})
                        feedback.play()
                        console.log("stop")
                    }
                }
            }
        }

        IconButton {
            iconName: "ios-settings"
            Layout.alignment: Qt.AlignCenter
            Layout.bottomMargin: parent.height * 0.1
            onClicked: layerStack.push(configLayer,{})
        }
    }

    Component.onCompleted: {
        rightIndicVisible = true
    }
}
