#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <huediscovery.h>

int main(int argc, char *argv[])
{
    qmlRegisterType<HueDiscovery>("tint.huediscovery", 1, 0, "HueDiscovery");
    // SailfishApp::main() will display "qml/cpp-test.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    return SailfishApp::main(argc, argv);
}
