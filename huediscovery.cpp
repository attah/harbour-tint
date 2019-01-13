#include "huediscovery.h"

HueDiscovery::HueDiscovery(QObject *parent) : QAbstractListModel(parent)
{
    socket = new QUdpSocket(this);
    connect(socket, SIGNAL(readyRead()),
            this, SLOT(readPendingDatagrams()));

}

HueDiscovery::~HueDiscovery() {
    delete socket;
}

int HueDiscovery::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return m_bridges.count();
}


QVariant HueDiscovery::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= m_bridges.count())
        return QVariant();

    const Bridge &bridge = m_bridges[index.row()];
    if (role == IdRole)
        return bridge.id();
    else if (role == InternalipaddressRole)
        return bridge.internalipaddress();
    return QVariant();
}


QHash<int, QByteArray> HueDiscovery::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[InternalipaddressRole] = "internalipaddress";
    return roles;
}

void HueDiscovery::reset() {
    beginResetModel();
    m_bridges.clear();
    endResetModel();
    discover();
}

void HueDiscovery::discover() {

    qDebug() << "Discovering!";

    QString message =
            (QStringList()
                << "M-SEARCH * HTTP/1.1"
                << "HOST: {0}:{1}"
                << "MAN: ssdp:discover"
                << "ST: {st}"
                << "MX: {mx}"
                << ""
                << "").join("\r\n");
    socket->writeDatagram(message.toUtf8(), QHostAddress("239.255.255.250"), 1900);

}


void HueDiscovery::readPendingDatagrams()
{
    while (socket->hasPendingDatagrams()) {
        QByteArray buffer;
        buffer.resize(socket->pendingDatagramSize());

        QHostAddress sender;
        quint16 senderPort;

        socket->readDatagram(buffer.data(), buffer.size(),
                             &sender, &senderPort);

        qDebug() << sender.protocol();

        sender = QHostAddress(sender.toIPv4Address());

        QString key = "hue-bridgeid:";
        int index = buffer.indexOf(key);
        if (index == -1)
            return;

        QString id = buffer.mid(index+key.length()+1, 16).toLower();
        QString internalipaddress = sender.toString();
        bool found = false;

        for(int i = 0; i < m_bridges.size(); i++)
        {
            if(m_bridges[i].id() == id)
            {
                found=true;
                if(m_bridges[i].internalipaddress() != internalipaddress)
                {
                    m_bridges[i].setInternalipaddress(internalipaddress);
                    emit dataChanged(this->index(i),this->index(i));
                }
            }
        }
        if(!found)
        {
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_bridges.append(Bridge(id,internalipaddress));
            endInsertRows();
        }

//        qDebug() << "Message from: " << internalipaddress;
//        qDebug() << "Message: " << id;
//        qDebug() << m_bridges.length();
    }
}
