import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property var bridge
    property bool suppress_refresh: false

    Component.onCompleted: {
        appWin.current_bridge = bridge;
    }

    Connections {
        target: wifi
        onConnectedChanged: {
            if(!wifi.connected) {
                pageStack.pop()
            }
        }
    }

    function populate() {
        groupsModel.clear();
        bridge.getGroup(0,
            function(attrs) {
                groupsModel.insert(0, {room_id: "0", room: attrs});
            },
            notifier.notifyMessage
        );
        bridge.getGroups(
            function(groups) {
                if(groups.length === 0) {
                    console.log('No groups found. :(');
                }
                else {
                    for (var g in groups) {
                        groupsModel.append({room_id: g, room: groups[g]})
                    };
                }
            },
            notifier.notifyMessage
        );
    }

    onVisibleChanged: {
        console.log("derp", visible, suppress_refresh)
        if (visible) {
            // Apparently refreshing interfers with the dialog.accepted.connect-ions, so they supress it (once)
            if(!suppress_refresh) {
                populate()
            }
            suppress_refresh = false
        }
    }

    ListModel {
        id: groupsModel
    }


    SilicaListView {
        id: listView
        model: groupsModel
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Rooms")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Bridge properties")
                onClicked: pageStack.push(Qt.resolvedUrl("BridgePropertiesPage.qml"), {bridge: bridge})
            }
            MenuItem {
                text: qsTr("Lights")
                onClicked: pageStack.push(Qt.resolvedUrl("LightsPage.qml"), {bridge: bridge})
            }
            MenuItem {
                text: qsTr("New group")
                onClicked: {var dialog = pageStack.push(Qt.resolvedUrl("InputDialog.qml"),
                                                        {value: qsTr("New group"), title: qsTr("Name")});
                            dialog.accepted.connect(function() {
                                bridge.createGroup({name: dialog.value, type: "Room",},
                                                function(success) {
                                                    console.log("light succ!",  JSON.stringify(success));
                                                    page.populate();
                                                },
                                                notifier.notifyMessage);
                        })
                }
            }
        }


        delegate: ListItem {
            id: delegate
//            Column {
//                id: roomcol
//                width: parent.width


                Row {
                    id: roomRow
                    anchors.fill: parent
                    Switch {
                        id: onoff
                        checked: room.state.any_on
                        enabled: room.lights !== []
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            bridge.setGroupState(room_id, {on: checked},
                                                 function(success) {
                                                     console.log("succ!", room_id,  JSON.stringify(success))
                                                     page.populate()
                                                 },
                                                 notifier.notifyMessage)
                        }
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: room_id == 0 ? qsTr("Global") : room.name
                    }
                }

            property bool longclicked: false
            onClicked: {longclicked = false;
                        if (onoff.checked) {
                            openMenu()
                        };
            }
            onPressAndHold: {longclicked = true;}
            menu: ContextMenu {
                id: normalMenu

                MenuItem {
                    visible: room_id != 0 && longclicked
                    text: qsTr("Edit group")
                    onClicked: {suppress_refresh = true;
                                var dialog = pageStack.push(Qt.resolvedUrl("EditGroupDialog.qml"),
                                                            {bridge: bridge, group_id: room_id, lights: room.lights});
                                dialog.accepted.connect(function() {
                                    if (dialog.lights) {
                                        console.log(dialog.lights);
                                        page.bridge.setGroup(room_id, {lights: dialog.lights},
                                                        function(success) {
                                                            console.log("light succ!", room_id,  JSON.stringify(success));
                                                            page.populate();
                                                        },
                                                        notifier.notifyMessage);
                                    }
                                })
                    }
                }

                MenuItem {
                    visible: room_id != 0 && longclicked
                    text: qsTr("Rename group")
                    onClicked: {suppress_refresh = true;
                                var dialog = pageStack.push(Qt.resolvedUrl("InputDialog.qml"),
                                                            {value: room.name, title: qsTr("Name")});
                                dialog.accepted.connect(function() {
                                    if (dialog.value !== room.name) {
                                        bridge.setGroup(room_id, {name: dialog.name},
                                                        function(success) {
                                                            console.log("light succ!", room_id,  JSON.stringify(success));
                                                            page.populate();
                                                        },
                                                        notifier.notifyMessage);
                                    }
                                })
                    }
                }

                MenuItem {
                    visible: room_id != 0 && longclicked
                    text: qsTr("Delete group")
                    onClicked: { Remorse.popupAction(page, qsTr("Deleting group"),
                                                     function() {bridge.deleteGroup(room_id,
                                                                                 function(success) {
                                                                                     console.log("del succ!", room_id,  JSON.stringify(success));
                                                                                     page.populate();
                                                                                 },
                                                                                 notifier.notifyMessage);
                                                                }
                                                     )
                               }
                }

                MenuItem {
                    visible: !longclicked && room.action.bri !== undefined

                    Image {
                        id: bri_icon
                        source: "image://theme/icon-m-day"
                    }

                    PacedSlider {
                        id: bri_slider
                        maximumValue: 254
                        width: parent.width
                        stepSize: 1
                        value: room.action.bri
                        onEvent: {
                            bridge.setGroupState(room_id, {bri: value},
                                                 function(success) {
                                                     console.log("succ!", room_id,  JSON.stringify(success))
                                                 },
                                                 notifier.notifyMessage)
                        }
                    }
                }
                MenuItem {
                    visible: !longclicked && room.action.ct !== undefined

                    Image {
                        id: ct_icon
                        source: "ct.png"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }
//                    Label {
//                        text: qsTr("Ct") // Color temperature
//                        anchors.verticalCenter: parent.verticalCenter
//                    }
                    PacedSlider {
                        id: ct_slider
                        minimumValue: 153
                        maximumValue: 500
                        width: parent.width
                        handleVisible: true
                        stepSize: 1
                        value: room.action.ct
                        onEvent: {
                            bridge.setGroupState(room_id, {ct: value},
                                                 function(success) {
                                                     console.log("succ!", room_id,  JSON.stringify(success))
                                                 },
                                                 notifier.notifyMessage)
                        }
                    }
                }
                MenuItem {
                    visible: !longclicked && room.action.hue !== undefined

                    Image {
                        id: hue_icon
                        source: "rgb.png"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }
//                    Label {
//                        text: qsTr("Hue")
//                        anchors.verticalCenter: parent.verticalCenter
//                    }
                    PacedSlider {
                        id: hue_slider
                        minimumValue: 0
                        maximumValue: 65535
                        width: parent.width
                        handleVisible: true
                        stepSize: 1
                        value: room.action.hue

                        backgroundGradient: Gradient {
                                                GradientStop {
                                                     position: 0.000
                                                     color: Qt.rgba(1, 0, 0, 1)
                                                  }
                                                  GradientStop {
                                                     position: 0.167
                                                     color: Qt.rgba(1, 0, 1, 1)
                                                  }
                                                  GradientStop {
                                                     position: 0.333
                                                     color: Qt.rgba(0, 0, 1, 1)
                                                  }
                                                  GradientStop {
                                                     position: 0.500
                                                     color: Qt.rgba(0, 1, 1, 1)
                                                  }
                                                  GradientStop {
                                                     position: 0.667
                                                     color: Qt.rgba(0, 1, 0, 1)
                                                  }
                                                  GradientStop {
                                                     position: 0.833
                                                     color: Qt.rgba(1, 1, 0, 1)
                                                  }
                                                  GradientStop {
                                                     position: 1.000
                                                     color: Qt.rgba(1, 0, 0, 1)
                                                  }
                                            }

                        onEvent: {
                            bridge.setGroupState(room_id, {hue: value},
                                                 function(success) {
                                                     console.log("succ!", room_id,  JSON.stringify(success))
                                                 },
                                                 notifier.notifyMessage)
                        }
                    }
                }
                MenuItem {
                    visible: !longclicked && room.action.sat !== undefined

                    Image {
                        id: sat_icon
                        source: "image://theme/icon-m-light-contrast"
                    }

//                    Label {
//                        text: qsTr("Sat")
//                        anchors.verticalCenter: parent.verticalCenter
//                    }
                    PacedSlider {
                        id: sat_slider
                        minimumValue: 0
                        maximumValue: 254
                        width: parent.width
                        handleVisible: true
                        stepSize: 1
                        value: room.action.sat
                        onEvent: {
                            bridge.setGroupState(room_id, {sat: value},
                                                 function(success) {
                                                     console.log("succ!", room_id,  JSON.stringify(success))
                                                 },
                                                 notifier.notifyMessage)
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
