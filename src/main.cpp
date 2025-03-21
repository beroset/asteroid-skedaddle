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

#include <asteroidapp.h>
#include "Voice.h"
#include "FileHelper.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<Voice>("org.asteroid.voice", 1, 0, "Voice");
    qmlRegisterSingletonType<FileHelper>("org.asteroid.filehelper", 1, 0, "FileHelper",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return FileHelper::instance();
        });

    return AsteroidApp::main(argc, argv);
}
