import QtQuick 2.0
import Sailfish.Silica 1.0

Slider {
    id: slider

    handleVisible: true
    property int synced_value: value
    property int pace: 500
    property var backgroundGradient

    property bool completed: false

    signal event

    Component.onCompleted: {if (backgroundGradient) {
                                _progressBarItem.opacity = 0;
                                _highlightItem.z = 1;
                            }
                            completed = true;
                           }

    Timer {
        id: pacer
        interval: pace; running: false; repeat: true
        onTriggered: { if (parent.value == parent.synced_value) {
                           pacer.stop()
                        }
                        else {
                            parent.sync()
                        }
                      }
    }

    function sync() {
        synced_value = value;
        event()
    }


    onValueChanged: {
        if (!pacer.running && completed) {
            pacer.start()
            sync()
        }
    }

    Rectangle {
        height: parent._grooveWidth
        width: 20
        anchors.centerIn: parent._backgroundItem
        rotation: 90
        visible: backgroundGradient != undefined
        gradient: backgroundGradient
    }


}
