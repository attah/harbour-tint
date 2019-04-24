import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    anchors.fill: parent

    property string value
    property string title
    canAccept: valueField.text !== ""

    Column {
        width: parent.width

        DialogHeader { }

        TextField {
            id: valueField
            width: parent.width
            placeholderText: value

            label: title
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            value = valueField.text
        }
    }

}
