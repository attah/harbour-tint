import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    anchors.fill: parent

    property var name
    canAccept: nameField.text !== ""

    Column {
        width: parent.width

        DialogHeader { }

        TextField {
            id: nameField
            width: parent.width
            placeholderText: name

            label: qsTr("Name")
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            name = nameField.text
        }
    }

}
