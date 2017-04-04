import QtQuick 2.6
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQml.Models 2.2
import QtQuick.LocalStorage 2.0

Item {
    id: root
    property var db
    property alias theDb: root.db

    function insertEvent(id, name) {
        events.append({ id: id, name: name });
    }

    function openEvent(id) {
        root.db.transaction(function(tx) {
            teilnehmer.clear();
            var rs = tx.executeSql("Select * from Teilnehmer Where Event_ID == '" + id + "'");
            if (rs.rows.length > 0)
                for(var i = 0; i < rs.rows.length; i++)
                    teilnehmer.append(rs.rows.item(i));
        })
    }

    Rectangle {
        anchors.fill: parent
        color: "#2c5a85"

        Rectangle {
            width: parent.width / 100 * 75
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            ListModel {
                id: events
            }
            ListModel {
                id: teilnehmer
            }

            Component {
                id: delegateEvent
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

            Rectangle {
                id: rectEvents
                border.width: 1
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 10
                width: 150
                ListView {
                    spacing: 2
                    clip: true
                    anchors.fill: parent
                    model: events
                    delegate: delegateEvent
                }
            }

            Rectangle {
                id: rectTeilnehmer
                border.width: 1
                anchors.top: parent.top
                anchors.leftMargin: 5
                anchors.left: rectEvents.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                ListView {
                    spacing: 2
                    clip: true
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5
                    anchors.fill: parent
                    model: teilnehmer
                    delegate: Component {
                        id: delegateTeilnehmer
                        Rectangle {
                            height: 45
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            width: parent.width
                            Text {
                                id: name
                                text: Nachname + " " + Vorname
                                font.pixelSize: 24
                            }
                            Text {
                                anchors.top: name.bottom
                                text: Gender == "m" ? "männlich" : "weiblich"
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }
}
