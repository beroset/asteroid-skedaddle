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

#include "FileHelper.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

Q_INVOKABLE bool FileHelper::writeFile(const QString& filePath, const QString& content) {
        QFile file(filePath);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream stream(&file);
            stream << content;
            file.close();
            return true;
        }
        qDebug() << "Writing file \"" << filePath << "\" FAILED:" << file.errorString();
        return false;
    }
Q_INVOKABLE QString FileHelper::readFile(const QString& filePath) {
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return "Error: Unable to open file.";
    }
    QTextStream in(&file);
    QString content = in.readAll();
    file.close();
    return content;
}
