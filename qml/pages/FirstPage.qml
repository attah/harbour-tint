import QtQuick 2.0
import Sailfish.Silica 1.0
import tint.huediscovery 1.0

Page {
    id: page
    property bool first_start: true

    onVisibleChanged: {
        if (visible)
            populate()
    }

    function populate() {
        console.log("pop");
        bridgesModel.reset();
    }

    HueDiscoveryModel {
        id: bridgesModel
    }

    Connections {
        target: wifi

        property bool initialSSIDchange: true

        onSsidChanged: {
            if(!initialSSIDchange)
            {
                populate()
            }
            initialSSIDchange = false;
        }
        onConnectedChanged: {
            if(wifi.connected == false)
            {
                first_start = true
            }
        }
    }

    Label {
        text: qsTr("Not on WiFi")
        color: Theme.highlightColor
        anchors.centerIn: parent
        visible: !wifi.connected
    }


    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id: listView
            model: bridgesModel
            anchors.fill: parent
            header: PageHeader {
                title: bridgesModel.count !== 0 ? qsTr("Available bridges") : qsTr("No bridges found")
            }


            PullDownMenu {
                MenuItem {
                    text: qsTr("Refresh")
                    onClicked: populate()
                }
            }

            delegate: ListItem {
                id: delegate
                property var bridge

                Component.onCompleted: {
                    bridge = hue_holder.hue.bridge(internalipaddress)
                    console.log(page.first_start, db.isFavourite(model.id), db.getUsername(model.id) != "");
                    if(page.first_start && db.isFavourite(model.id) && db.getUsername(model.id) != "") {
                        page.first_start = false;
                        pageStack.push(Qt.resolvedUrl("BridgePage.qml"), {bridge: bridge.user(db.getUsername(model.id))});
                    }
                }

                Row {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Label    {
                        text: qsTr("Bridge") + " " + (index+1) + ": " + model.id
                        anchors.verticalCenter: parent.verticalCenter
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                        width: parent.width - known.width
                        leftPadding: Theme.horizontalPageMargin
                    }
                    IconButton {
                        id: known
                        icon.source: "image://theme/icon-m-certificates"
                        onClicked: {}

                        anchors.verticalCenter: parent.verticalCenter
                        enabled: db.getUsername(model.id) !== ""
                    }
                }
                onClicked: {
                             console.log("db", db );
                             if (known.enabled) {
                                db.setFavourite(model.id);
                                pageStack.push(Qt.resolvedUrl("BridgePage.qml"), {bridge: bridge.user(db.getUsername(model.id))})
                             }
                             else {
                                var dialog = pageStack.push(Qt.resolvedUrl("PairDialog.qml"), {bridge: bridge})
                                dialog.accepted.connect(
                                    function(bridge_id, db) {
                                        return function() {
                                            console.log("db2", db);
                                            if (dialog.username) {
                                                db.addHub(bridge_id, dialog.username);
                                                known.enabled = db.getUsername(bridge_id) !== "";
                                            }
                                        }
                                    }(model.id, db)
                                )
                            }
                }

            menu: ContextMenu {
                id: contextMenu
                hasContent: known.enabled
                MenuItem {
                    text: qsTr("Unpair")
                    onClicked: {
                        Remorse.popupAction(page, qsTr("Unpairing bridge"),
                            function() {
                                var username = db.getUsername(id);
                                if (username != "") {
                                    bridge.user(username).deleteUser(username,
                                                      function(success) {
                                                          console.log("DeleteUser success", JSON.stringify(success))
                                                      },
                                                      notifier.notifyMessage
                                                     )
                                };
                                db.removeHub(id);
                                known.enabled = db.getUsername(id) !== "";
                            }
                         )
                    }
                }
            }

            VerticalScrollDecorator {}
            }
        }
    }
}
