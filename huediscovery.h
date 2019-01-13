#ifndef HUEDISCOVERY_H
#define HUEDISCOVERY_H

#include <QObject>
#include <QUdpSocket>
#include <QAbstractListModel>

class Bridge
{
    Q_GADGET
    Q_PROPERTY(QString id READ id)
    Q_PROPERTY(QString internalipaddress READ internalipaddress WRITE setInternalipaddress)
public:
    Bridge(const QString& id, const QString& internalipaddress)
    {
        m_id = id;
        m_internalipaddress = internalipaddress;
    }
    const QString& id() const {return m_id;}
    const QString& internalipaddress() const {return m_internalipaddress;}
    void setInternalipaddress(const QString& ip) {m_internalipaddress = ip;}

private:
    QString m_id;
    QString m_internalipaddress;
};

class HueDiscovery : public QAbstractListModel
{
    Q_OBJECT
    QUdpSocket* socket;

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        InternalipaddressRole
    };

    explicit HueDiscovery(QObject *parent = nullptr);
    ~HueDiscovery();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void discover();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    const QList<Bridge>& bridges() {return m_bridges;}

signals:

public slots:
    void readPendingDatagrams();
protected:
    QHash<int, QByteArray> roleNames() const;
private:
    QList<Bridge> m_bridges;
};

#endif // HUEDISCOVERY_H
