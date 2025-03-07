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
}
