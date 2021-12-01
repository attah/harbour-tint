#include <QtQuick>
#include <QCryptographicHash>
#include <sailfishapp.h>
#include <huediscovery.h>

void migrateLocalStorage()
{
    // The new location of the LocalStorage database
    QDir newDbDir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/net.attah/tint/QML/OfflineStorage/Databases/");

    if(newDbDir.exists())
        return;

    newDbDir.mkpath(newDbDir.path());

    QString dbname = QString(QCryptographicHash::hash(("TintDB"), QCryptographicHash::Md5).toHex());
    // The new LocalStorage database
    QFile newDb(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/net.attah/tint/QML/OfflineStorage/Databases/" + dbname + ".sqlite");
    QFile newIni(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/net.attah/tint/QML/OfflineStorage/Databases/" + dbname + ".ini");

    // The old LocalStorage database
    QFile oldDb(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/harbour-tint/harbour-tint/QML/OfflineStorage/Databases/" + dbname + ".sqlite");
    QFile oldIni(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/harbour-tint/harbour-tint/QML/OfflineStorage/Databases/" + dbname + ".ini");

    oldDb.open(QFile::ReadOnly);
    oldIni.open(QFile::ReadOnly);
    newDb.open(QFile::WriteOnly);
    newIni.open(QFile::WriteOnly);

    newDb.write(oldDb.readAll());
    newIni.write(oldIni.readAll());
}


int main(int argc, char *argv[])
{
    migrateLocalStorage();

    QGuiApplication* app = SailfishApp::application(argc, argv);

    app->setOrganizationName(QStringLiteral("net.attah"));
    app->setApplicationName(QStringLiteral("tint"));

    qmlRegisterType<HueDiscovery>("tint.huediscovery", 1, 0, "HueDiscoveryModel");

    QQuickView* view = SailfishApp::createView();

    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();

    return SailfishApp::main(argc, argv);
}
