import QtQuick 2.6
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3

Item {
    height: 290
    Image {
        id: headerBG
        x: 0
        y: 0
        height: 225
        anchors.left: parent.left
        anchors.right: parent.right
        source: "images/headerbg.png"

        Image {
            id: headerLogo
            width: 850
            height: 75
            anchors.top: parent.top
            anchors.topMargin: 36
            anchors.rightMargin: 25
            anchors.right: parent.right
            source: "images/logo.png"
        }

        Image {
            id: headerOverlay
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: -380
            anchors.right: parent.right
            source: "images/headeroverlay.png"
        }

        Label {
            id: headerText
            height: 40
            anchors.rightMargin: 25
            anchors.right: parent.right
            color: "#ffffff"
            text: qsTr("Schwabens ältester Schwimmverein")
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            font.pointSize: 24
        }
    }

    Rectangle {
        id: blackLine
        height: 10
        color: "#3f3f3f"
        anchors.topMargin: -20
        anchors.top: headerBG.bottom
        anchors.right: parent.right
        anchors.left: parent.left
    }

    Rectangle {
        id: whiteLine
        height: 75
        color: "#ffffff"
        anchors.top: blackLine.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        Label {
            id: title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: "#3f3f3f"
            text: qsTr("Ammerseeschwimmen")
            font.pointSize: 32
            font.bold: true
        }
    }
}
