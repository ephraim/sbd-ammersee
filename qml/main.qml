import QtQuick 2.6
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2

ApplicationWindow {
    visible: true
    visibility: "FullScreen"
    title: qsTr("Hello World")

    Header {
        id: header
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
    }

    MainForm {
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.bottom: parent.bottom

        button1.onClicked: messageDialog.show(qsTr("Button 1 pressed"))
        button2.onClicked: Qt.quit()
    }
}
