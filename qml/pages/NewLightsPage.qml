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
                    function(error) {
                        console.error(JSON.stringify(error));
                    }
                );
    }

    function getNewLights() {
        bridge.getNewLights(
            function(lights) {
                console.log(JSON.stringify(lights))
                if(lights.length === 0) {
                    console.log('No lights found. :(');
                }
                else if (lights.lastscan !== "active") {
                    retry.stop();
                    bridgesModel.clear();
                    for (var l in lights) {
                        if (l === "lastscan")
                            continue
                        bridgesModel.append({light_id: l, light: lights[l]})
                    };
                }
                active_scan = lights.lastscan === "active";
            },
            function(error) {
                console.error(error.message);
            }
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
//            MenuItem {
//                text: qsTr("Search by ID")
//                onClicked: {console.log("Search by ID")}
//            }
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
