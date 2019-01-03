import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    anchors.fill: parent

    property var bridge
    property var group_id

    property var lights: []

    Component.onCompleted: {

        bridge.getLights(
            function(lights) {
                if(lights.length === 0) {
                    console.log('No lights found. :(');
                }
                else {
                    for (var l in lights) {
                        console.log("ll",l);
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

    DialogHeader {
        id: dialogHeader
    }


    SilicaListView {
        id: listView
        model: lightsModel
        anchors.fill: parent
        anchors.topMargin: dialogHeader.height

        delegate: ListItem {
            id: delegate


                onClicked: {
                    chosen.checked = !chosen.checked
                }

                Row {
                    id: lightRow
                    anchors.fill: parent

                    Switch {
                        id: chosen
                        checked: lights.indexOf(light_id) !== -1
                        anchors.verticalCenter: parent.verticalCenter
                        onCheckedChanged: {
                            // Always remove, maybe add (initializing counts as changing -.-')
                            lights = lights.filter(function filter(elem) {return elem !== light_id})
                            if(chosen.checked) {
                                lights.push(light_id)
                            };
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

        }
        VerticalScrollDecorator {}
    }


}
