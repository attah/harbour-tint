import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    canAccept: false

    property string username
    property var bridge

    Timer {
        id: retry
        interval: 1000; running: true; repeat: true
        onTriggered: { bridge.createUser("Tint",
                                         function(success) {
                                             retry.stop();
                                             console.log(JSON.stringify(success));
                                             username=success[0].success.username;
                                             done.visible = true;
                                             canAccept = true;
                                             console.log(username)
                                         },
                                         function(error){console.log(error)}); //some errors are expected until press happens, don't bother the user
                        console.log("boop");}
    }

    Column {
        width: parent.width

        DialogHeader {
            title: qsTr("Pairing")
        }

        Label {
            id: nameField
            x: Theme.paddingMedium
            width: parent.width
            text: qsTr("Press the pairing button")
        }

        Label {
            id: done
            x: Theme.paddingMedium
            visible: false
            width: parent.width
            text: qsTr("Success!")
        }
//        Image {
//            id: success
//            anchors.horizontalCenter: parent.horizontalCenter
////            anchors.verticalCenter: parent.verticalCenter
//            source: "image://theme/icon-l-acknowledge"

//        }
    }


}
