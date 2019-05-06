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

    function getNewSensors() {
        bridge.getNewSensors(
            function(sensors) {
                console.log(JSON.stringify(sensors))
                if(sensors.length === 0) {
                    console.log('No sensors found. :(');
                }
                else {
                    bridgesModel.clear();
                    for (var l in sensors) {
                        if (l === "lastscan")
                            continue
                        bridgesModel.append({sensor_id: l, sensor: sensors[l]})
                    };
                }
                if (sensors.lastscan !== "active")
                    retry.stop();

                active_scan = sensors.lastscan === "active";
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
        onTriggered: { getNewSensors(); }
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
            title: qsTr("New Sensors")
        }

        PullDownMenu {
            id: searchMenu
            busy: retry.running
            MenuItem {
                text: qsTr("Search again")
                onClicked: {console.log("Search again"); search()}
            }
        }

        delegate: ListItem {
            id: delegate

                Row {
                    id: sensorRow
                    anchors.fill: parent


                    Label {
                        x: Theme.horizontalPageMargin
                        text: sensor.name
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                }

        }
        VerticalScrollDecorator {}
    }
}
