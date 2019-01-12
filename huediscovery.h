#ifndef HUEDISCOVERY_H
#define HUEDISCOVERY_H

#include <QObject>

class HueDiscovery : public QObject
{
    Q_OBJECT
public:
    explicit HueDiscovery(QObject *parent = nullptr);

signals:

public slots:
};

#endif // HUEDISCOVERY_H