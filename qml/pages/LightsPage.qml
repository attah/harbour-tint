import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property var bridge

    Component.onCompleted: {
        bridge.getLights(
            function(lights) {
                if(lights.length === 0) {
                    console.log('No lights found. :(');
                }
                else {
                    for (var l in lights) {
                        lightsModel.append({light_id: l, light: lights[l]})
                    };
                }
            },
            function(error) {
                console.error(error.message);
            }
        );
    }

    ListModel {
        id: lightsModel
    }


    SilicaListView {
        id: listView
        model: lightsModel
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Lights")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("New Lights")
                onClicked: pageStack.push(Qt.resolvedUrl("NewLightsPage.qml"), {bridge: bridge})
            }
        }

        delegate: ListItem {
            id: delegate

                Row {
                    id: lightRow
                    anchors.fill: parent

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            x: Theme.horizontalPageMargin
                            text: light.name
                            color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label {
                            x: Theme.horizontalPageMargin
                            text: light.type
                            font.pixelSize: Theme.fontSizeTiny
                        }
                    }
                }

        }
        VerticalScrollDecorator {}
    }
}
