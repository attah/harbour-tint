import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property var bridge

    function populate() {
        lightsModel.clear();
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

    onVisibleChanged: {
        console.log("status", status);
        if (visible) {
            console.log("pop");
            populate()
        }
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

                Switch {
                    id: onoff
                    checked: light.state.on
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        bridge.setLightState(light_id, {on: checked},
                                             function(success) {
                                                 console.log("succ!", light_id,  JSON.stringify(success))

                                             },
                                             function(error) {
                                                console.log("err!", JSON.stringify(error))

                                             })
                    }
                }

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
            menu: ContextMenu {
                id: contextMenu

                MenuItem {
                    text: qsTr("Rename light")
                    onClicked: {var dialog = pageStack.push(Qt.resolvedUrl("RenameGroupDialog.qml"),
                                                            {name: light.name});
                                dialog.accepted.connect(function() {
                                    if (dialog.name !== light.name) {
                                        bridge.setLight(light_id, {name: dialog.name},
                                                        function(success) {
                                                            console.log("light succ!", light_id,  JSON.stringify(success));
                                                            page.populate();
                                                        },
                                                        function(error) {
                                                           console.log("err!", JSON.stringify(error))
                                                        });
                                    }
                                })
                    }
                }
                MenuItem {
                    text: qsTr("Delete light")
                    onClicked: { Remorse.popupAction(page, qsTr("Deleting light"),
                                                     function() {bridge.deleteLight(light_id,
                                                                                    function(success) {
                                                                                        console.log("del succ!", light_id,  JSON.stringify(success));
                                                                                        page.populate();
                                                                                    },
                                                                                    function(error) {
                                                                                       console.log("err!", JSON.stringify(error))
                                                                                    });})
                               }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
