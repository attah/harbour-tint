import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    canAccept: false
    anchors.fill: parent

    property string username
    property var bridge

    Timer {
        id: retry
        interval: pace; running: true; repeat: true
        onTriggered: { bridge.createUser("Tint",
                                         function(success) {
                                             if (success[0].error)
                                                 return;
                                             retry.stop();
                                             console.log(JSON.stringify(success));
                                             username=success[0].success.username;
                                             done.visible = true;
                                             canAccept = true;
                                             console.log(username)
                                         },
                                         function(error) {
                                             console.log(error)
                                         });
                        console.log("boop");}
    }

    Column {
        width: parent.width

        DialogHeader {
            title: "Pairing"
        }

        Label {
            id: nameField
            x: Theme.paddingMedium
            width: parent.width
            text: "Press the pairing button"
        }

        Label {
            id: done
            x: Theme.paddingMedium
            visible: false
            width: parent.width
            text: "Success!"
        }
        Image {
            id: success
            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter: parent.verticalCenter
            source: "image://theme/icon-l-acknowledge"

        }
    }


}
