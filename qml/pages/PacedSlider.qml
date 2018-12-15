import QtQuick 2.0
import Sailfish.Silica 1.0

Slider {

    handleVisible: true
    property int synced_value: value
    property int pace: 500

    property bool completed: false

    signal event

    Component.onCompleted: {completed = true}

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

}
