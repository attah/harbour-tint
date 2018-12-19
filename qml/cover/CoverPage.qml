import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    onVisibleChanged: {
        console.log("covis", visible)
        refresh();
    }

    function refresh() {
        connected = false;
        if(appWin.current_bridge === undefined) {
            return;
        }
        appWin.current_bridge.getGroup(0,
            function(attrs) {
                if(attrs === "") {
                    return;
                }
                else {
                    connected = true;
                    global_state = attrs.state.any_on;
                }
            },
            function(error) {
                console.error(error.message);
            }
        );
    }

    property bool global_state: false
    property bool connected: false

        Image {
            id: coverImage
            source: "tint-angle.png"
            height: parent.width * (360/300) * 1.2
            width: parent.width * 1.2
            opacity: 0.2
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: label
            anchors.centerIn: parent
            text: qsTr("Tint")
            anchors.horizontalCenter: parent.horizontalCenter
        }
        CoverActionList {
            id: coverAction


            CoverAction {
                iconSource: connected ? (global_state ? "bulb-switch-on-glow.png" : "bulb-switch-off.png") : "bulb-switch-unavail.png"
                onTriggered: {
                    if (connected) {
                        appWin.current_bridge.setGroupState(0, {on: !global_state},
                                                           function(success) {
                                                               console.log("succ!", 0,  JSON.stringify(success));
                                                               refresh();
                                                           },
                                                           function(error) {
                                                              console.log("err!", JSON.stringify(error))
                                                           })
                    }
                }
            }
        }

}
