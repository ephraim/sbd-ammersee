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
        eventsView.modelEvents.append({ id: id, name: name });
    }

    function openEvent(id) {
        content.state = "";
        root.db.transaction(function(tx) {
            teilnehmerView.modelTeilnehmer.clear();
            var rs = tx.executeSql("Select * from Teilnehmer Where Event_ID == '" + id + "'");
            if (rs.rows.length > 0)
                for(var i = 0; i < rs.rows.length; i++)
                    teilnehmerView.modelTeilnehmer.append(rs.rows.item(i));
        });
    }

    function showAddEvent() {
        content.state = "addEvent";
    }

    Rectangle {
        anchors.fill: parent
        color: "#2c5a85"

        Rectangle {
            id: content
            width: parent.width / 100 * 75
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            EventsView {
                id: eventsView
                border.width: 1
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 10
                width: 150
            }

            TeilnehmerListView {
                id: teilnehmerView
                border.width: 1
                anchors.top: parent.top
                anchors.leftMargin: 5
                anchors.left: eventsView.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
            }

            AddEventForm {
                id: addEventForm
                border.width: 1
                anchors.top: parent.top
                anchors.leftMargin: 5
                anchors.left: eventsView.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                visible: false
            }

            states: [
                State {
                    name: "addEvent"
                    PropertyChanges { target: teilnehmerView; visible: false }
                    PropertyChanges { target: addEventForm;   visible: true }
                }
            ]
        }
    }
}
