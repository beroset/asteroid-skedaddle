#include "SatelliteSourceBridge.h"

SatelliteSourceBridge::SatelliteSourceBridge(QObject *parent)
    : QObject(parent)
{
    source = QGeoSatelliteInfoSource::createDefaultSource(this);
    if (!source)
        return;

    connect(source, &QGeoSatelliteInfoSource::satellitesInUseUpdated,
            this, &SatelliteSourceBridge::onUpdate);
    connect(source, &QGeoSatelliteInfoSource::satellitesInViewUpdated,
            this, &SatelliteSourceBridge::onUpdate);

    source->startUpdates();
}

void SatelliteSourceBridge::onUpdate(const QList<QGeoSatelliteInfo> &list)
{
    if (sender() == source)
        m_inView = list.size();
    emit satellitesChanged();
}
