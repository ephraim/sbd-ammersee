import QtQuick 2.6
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    id: window
    visible: true
    visibility: "FullScreen"
    title: qsTr("SB Delphin Augsburg 03 - Ammerseeschwimmen")
    property var db: LocalStorage.openDatabaseSync("schimmen.sqlite", "1.0", "The Example QML SQL!", 1000000);

    Component.onCompleted: {
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 'Teilnehmer' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT, 'Vorname' TEXT, 'Nachname' TEXT, 'Gebtag' TEXT, 'Startnr' TEXT, 'Gender' TEXT, 'Visitor' BOOLEAN, 'IDTAG' INTEGER, 'Event_ID' INTEGER, 'Endzeit' INTEGER DEFAULT 0);");
            tx.executeSql("CREATE TABLE IF NOT EXISTS 'Event' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, 'EventName' TEXT, 'Startzeit' INTEGER DEFAULT 0, 'done' BOOLEAN DEFAULT 0);");
            // tx.executeSql("INSERT INTO 'Event' ('EventName') VALUES ('2017'), ('2016')");
            // tx.executeSql("insert into Teilnehmer ('Vorname', 'Nachname', 'GebTag', 'Startnr', 'Gender', 'Visitor', 'IDTAG', 'Event_ID') VALUES ('Flavia', 'Cestonaro', 'gebtag', '10', 'w', 0, 12435365, 2);");

            var rs = tx.executeSql("SELECT * FROM Event");
            for(var i = 0; i < rs.rows.length; i++) {
                mainform.insertEvent(rs.rows.item(i).ID, rs.rows.item(i).EventName)
            }
        });
    }

    Header {
        id: header
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
    }

    Mainform {
        id: mainform
        theDb: window.db
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
    }
}
