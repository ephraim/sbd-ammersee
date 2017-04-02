import QtQuick 2.6
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3

Item {
    id: item1

    property alias button1: button1
    property alias button2: button2

    Rectangle {
        anchors.fill: parent
        color: "#2c5a85"

        Rectangle {
            width: parent.width / 100 * 70
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                anchors.centerIn: parent

                Button {
                    id: button1
                    text: qsTr("Press Me 1")
                }

                Button {
                    id: button2
                    text: qsTr("Press Me 2")
                }
            }
        }
    }
}
