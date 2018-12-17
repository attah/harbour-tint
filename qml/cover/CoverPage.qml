import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Column {
        anchors.fill: parent
        spacing: Theme.paddingLarge
        Image {
            id: coverImage
            source: "tint.png"
            height: parent.width
            width: parent.width * (235/377)
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: label
//            anchors.centerIn: parent
            text: qsTr("Tint")
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
