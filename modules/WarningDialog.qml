import QtQuick 2.12
import QtQuick.Controls 2.12

Dialog {
    property bool        rewrite: false
    property alias   warningText: _label.text
    property var  acceptFunction: function() { return true; }
    property var  rejectFunction: function() {}

    width: 400
    modal: true
    focus: true
    anchors.centerIn: parent
    standardButtons: Dialog.Save | Dialog.No
    closePolicy: Popup.NoAutoClose | Popup.CloseOnEscape
    contentItem: Rectangle {
        Text {
            id: _label
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
    onAccepted: acceptFunction()
    onRejected: rejectFunction()
}
