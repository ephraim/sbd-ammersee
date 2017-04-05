import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	property alias modelEvents: events

    ListModel {
        id: events
    }

    ListView {
        spacing: 2
        clip: true
        anchors.fill: parent
        model: events
        delegate: Component {
            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                width: parent.width
                text: name
                font.pixelSize: 24
                MouseArea {
                    anchors.fill: parent
                    onClicked: openEvent(id)
                }
            }
        }
        footer: Component {
            Rectangle {
                height: 25
                anchors.right: parent.right
                anchors.rightMargin: 5
                width: 20
                color: "#afafaf"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "+"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: showAddEvent()
                }
            }
        }
    }
}
