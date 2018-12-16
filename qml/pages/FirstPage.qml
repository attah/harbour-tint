import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        Component.onCompleted: {
            hue_holder.hue.discover(
                function(bridges) {
                    if(bridges.length === 0) {
                        console.log('No bridges found. :(');
                    }
                    else {
                        bridges.forEach(function(b) {
                            console.log('Bridge found at IP address %s.', b.internalipaddress, b.id);
                            bridgesModel.append(b);
                        });
                    }
                },
                function(error) {
                    console.error(error.message);
                }
            );
        }

        ListModel {
            id: bridgesModel
        }


        SilicaListView {
            id: listView
            model: bridgesModel
            anchors.fill: parent
            header: PageHeader {
                title: bridgesModel.count !== 0 ? "Available bridges" : "No bridges found"
            }
            delegate: ListItem {
                id: delegate
                property var bridge

                Component.onCompleted: {
                    bridge = hue_holder.hue.bridge(internalipaddress)
                }

                Row {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Label    {
                        text: qsTr("Hub") + " " + (index+1) + ": " + id
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
                        enabled: db.getUsername(id) !== ""
                    }
                }
                onClicked: { if (known.enabled) {
                                 pageStack.push(Qt.resolvedUrl("BridgePage.qml"), {bridge: bridge.user(db.getUsername(id))})
                             }
                             else {
                                var dialog = pageStack.push(Qt.resolvedUrl("PairDialog.qml"), {bridge: bridge});
                                dialog.accepted.connect(function() {
                                    if (dialog.username) {
                                        db.addHub(id, dialog.username);
                                        known.enabled = db.getUsername(id) !== "";
                                    }
                                })
                            }
                }

            menu: ContextMenu {
                id: contextMenu
                hasContent: known.enabled
                MenuItem {
                    text: "Unpair"
                    onClicked: {
                        var username = db.getUsername(id);
                        if (username != "") {
                            bridge.user(username).deleteUser(username,
                                              function(success) {
                                                  console.log("DeleteUser success", JSON.stringify(success))
                                              },
                                              function(error) {
                                                  console.log("DeleteUser error", JSON.stringify(error))
                                              }
                                             )
                        };
                        db.removeHub(id);
                        known.enabled = db.getUsername(id) !== "";
                    }
                }
            }

            VerticalScrollDecorator {}
            }
        }
    }
}
