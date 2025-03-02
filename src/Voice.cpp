/*
 * Copyright (C) 2025 - Ed Beroset <beroset@ieee.org>
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

#include <iostream>
#include <cstring>
#include <stdexcept>
#include "Voice.h"

Voice::Voice(QObject *parent) 
    : QObject(parent)
{
    // Initialize eSpeak
    if (espeak_Initialize(AUDIO_OUTPUT_PLAYBACK, 0, nullptr, 0) == -1) {
        throw std::runtime_error("Failed to initialize eSpeak.");
    }
    memset(&voice, 0, sizeof(espeak_VOICE)); // Clear structure
}

QString Voice::libVersion() const
{
    return espeak_Info(nullptr);
}

Voice::~Voice() 
{
    espeak_Terminate();
}

void Voice::say(QString message)
{
    std::string msg = message.toStdString();
    espeak_Synth(msg.c_str(), msg.size() + 1, 0, POS_CHARACTER, 0, 
                 espeakCHARS_AUTO, nullptr, nullptr);

    // Wait for the speech to complete
    //espeak_Synchronize();
}

void Voice::setProperties(QString languages, int gender, int variant, int age)
{
    /*
     * Qt specifies locale language string as something like "en_GB"
     * but espeak wants them in the form "en-uk".  Since we don't know
     * how to translate the latter (yet!) we just trim the language
     * part and hope for the best.
     */
    std::string lang = languages.toStdString();
    lang.erase(lang.find('_'), std::string::npos);
    
    voice.languages = lang.c_str();
    voice.gender = gender;
    voice.variant = variant;
    voice.age = age;
    espeak_SetVoiceByProperties(&voice);
}

#if VOICE_EXAMPLE
int main() {
    Voice v("en", 2, 4);
    v.say("Time: 9 minutes 3.5 seconds");
    v.setProperties("fr", 2, 0);
    v.say("Durée : 9 minutes 3,5 secondes");
    v.setProperties("es", 2, 2);
    v.say("tiempo: 9 minutos 3,5 segundos");
    v.setProperties("de", 2, 0);
    v.say("Zeit: 9 Minuten 3,5 Sekunde");
    v.setProperties("it", 2, 0);
    v.say("tempo: 9 minuti 3,5 secondi");
}
#endif
