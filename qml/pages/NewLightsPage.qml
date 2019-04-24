import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property var bridge
    property bool active_scan: false

    function search() {
        console.log("searching");
        active_scan = true;
        bridge.searchForNewLights(
                    function(success) {
                        console.log(JSON.stringify(success))
                    },
                    notifier.notifyMessage
                );
    }

    function getNewLights() {
        bridge.getNewLights(
            function(lights) {
                console.log(JSON.stringify(lights))
                if(lights.length === 0) {
                    console.log('No lights found. :(');
                }
                else {
                    bridgesModel.clear();
                    for (var l in lights) {
                        if (l === "lastscan")
                            continue
                        bridgesModel.append({light_id: l, light: lights[l]})
                    };
                }
                if (lights.lastscan !== "active")
                    retry.stop();

                active_scan = lights.lastscan === "active";
            },
            notifier.notifyMessage
        );
    }

    function touchLink() {
        console.log("searching");
        active_scan = true;
        bridge.setConfig({touchlink: true},
                    function(success) {
                        console.log(JSON.stringify(success))
                    },
                    notifier.notifyMessage
                );
    }

    Timer {
        id: retry
        interval: 500; running: active_scan; repeat: true
        onTriggered: { getNewLights(); }
    }


    Component.onCompleted: {
        search();
    }

    ListModel {
        id: bridgesModel
    }


    SilicaListView {
        id: listView
        model: bridgesModel
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("New Lights")
        }

        PullDownMenu {
            id: searchMenu
            busy: retry.running
            MenuItem {
                text: qsTr("Enable TouchLink")
                onClicked: touchLink()
            }
            MenuItem {
                text: qsTr("Search by ID")
                onClicked: {var dialog = pageStack.push(Qt.resolvedUrl("InputDialog.qml"),
                                                        {value: qsTr("Search by ID"), title: qsTr("ID")});
                    dialog.accepted.connect(function() {
                        bridge.searchForNewLightsById([dialog.value],
                                        function(success) {
                                            console.log("light serach by id succ!",  JSON.stringify(success));
                                            page.getNewLights();
                                        },
                                        notifier.notifyMessage);
                        })
                }            }
            MenuItem {
                text: qsTr("Search again")
                onClicked: {console.log("Search again"); search()}
            }
        }

        delegate: ListItem {
            id: delegate

                Row {
                    id: lightRow
                    anchors.fill: parent


                    Label {
                        x: Theme.horizontalPageMargin
                        text: light.name
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                }

        }
        VerticalScrollDecorator {}
    }
}
