import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property var bridge

    function populate() {
        sensorsModel.clear();
        bridge.getSensors(
            function(sensors) {
                if(sensors.length === 0) {
                    console.log('No sensors found. :(');
                }
                else {
                    for (var l in sensors) {
                        sensorsModel.append({sensor_id: l, sensor: sensors[l]})
                    };
                }
            },
            notifier.notifyMessage
        );
    }

    onVisibleChanged: {
        console.log("status", status);
        if (visible) {
            console.log("pop");
            populate()
        }
    }

    ListModel {
        id: sensorsModel
    }


    SilicaListView {
        id: listView
        model: sensorsModel
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Sensors")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("New Sensors")
                onClicked: pageStack.push(Qt.resolvedUrl("NewSensorsPage.qml"), {bridge: bridge})
            }
        }

        delegate: ListItem {
            id: delegate


            Label {
                id: nameLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: sensor.name
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            Label {
                anchors.top: nameLabel.bottom
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: sensor.type
                font.pixelSize: Theme.fontSizeTiny
            }
            Label {
                anchors.top: nameLabel.bottom
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                text: sensor.config.battery
                font.pixelSize: Theme.fontSizeTiny
            }


            menu: ContextMenu {
                id: contextMenu

                MenuItem {
                    text: qsTr("Rename sensor")
                    onClicked: {var dialog = pageStack.push(Qt.resolvedUrl("InputDialog.qml"),
                                                            {name: sensor.name});
                                dialog.accepted.connect(function() {
                                    if (dialog.name !== sensor.name) {
                                        bridge.setSensor(sensor_id, {name: dialog.name},
                                                        function(success) {
                                                            console.log("sense succ!", sensor_id,  JSON.stringify(success));
                                                            page.populate();
                                                        },
                                                        notifier.notifyMessage);
                                    }
                                })
                    }
                }
                MenuItem {
                    text: qsTr("Delete sensor")
                    onClicked: { Remorse.popupAction(page, qsTr("Deleting sensor"),
                                                     function() {bridge.deleteSensor(sensor_id,
                                                                                    function(success) {
                                                                                        console.log("del succ!", sensor_id,  JSON.stringify(success));
                                                                                        page.populate();
                                                                                    },
                                                                                    notifier.notifyMessage);
                                                                }
                                                     )
                               }
                }
            }

        }
        VerticalScrollDecorator {}
    }
}
