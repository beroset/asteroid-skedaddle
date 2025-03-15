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
#ifndef FILEHELPER_H
#define FILEHELPER_H
#include <QObject>
#include <QString>
#include <QQmlEngine>

class FileHelper : public QObject{
    Q_OBJECT
public:
    static FileHelper *instance() {
        static FileHelper instance;
        return &instance;
    }
    Q_INVOKABLE bool writeFile(const QString& filePath, const QString& content);
    Q_INVOKABLE QString readFile(const QString& filePath);
private:
    explicit FileHelper(QObject *parent = nullptr) : QObject(parent) {};
    ~FileHelper() = default;
    FileHelper(const FileHelper&) = delete;
    FileHelper &operator=(const FileHelper&) = delete;
};
#endif // FILEHELPER_H
