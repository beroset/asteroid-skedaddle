#ifndef SATELLITESOURCEBRIDGE_H
#define SATELLITESOURCEBRIDGE_H
#include <QObject>
#include <QtPositioning/QGeoSatelliteInfoSource>

class SatelliteSourceBridge : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int satellitesInUse READ satellitesInUse NOTIFY satellitesChanged)
    Q_PROPERTY(int satellitesInView READ satellitesInView NOTIFY satellitesChanged)

public:
    SatelliteSourceBridge(QObject *parent = nullptr);
    int satellitesInUse() const { return m_inUse; }
    int satellitesInView() const { return m_inView; }

signals:
    void satellitesChanged();

private slots:
    void onUpdate(const QList<QGeoSatelliteInfo> &list);

private:
    QGeoSatelliteInfoSource *source = nullptr;
    int m_inUse = 0;
    int m_inView = 0;
};

#endif // SATELLITESOURCEBRIDGE_H
