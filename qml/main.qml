import QtQuick 2.6
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0

ApplicationWindow {
	id: root
	visible: true
	visibility: "FullScreen"
	title: qsTr("SB Delphin Augsburg 03 - Ammerseeschwimmen")
	property var db: LocalStorage.openDatabaseSync("schimmen.sqlite", "1.0", "The Example QML SQL!", 1000000);

	Component.onCompleted: {
		db.transaction(function(tx) {
			tx.executeSql("CREATE TABLE IF NOT EXISTS 'Teilnehmer' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, 'Vorname' TEXT, 'Nachname' TEXT, 'Gebtag' TEXT, 'Startnr' INTEGER UNIQUE, 'Gender' TEXT, 'Visitor' BOOLEAN, 'IDTAG' TEXT UNIQUE, 'Event_ID' INTEGER, 'Endzeit' INTEGER DEFAULT 0);");
			tx.executeSql("CREATE TABLE IF NOT EXISTS 'Event' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, 'EventName' TEXT, 'Startzeit' INTEGER DEFAULT 0, 'Endzeit' INTEGER DEFAULT 0);");
			// tx.executeSql("INSERT INTO 'Event' ('EventName') VALUES ('2017'), ('2016')");
			// tx.executeSql("insert into Teilnehmer ('Vorname', 'Nachname', 'GebTag', 'Startnr', 'Gender', 'Visitor', 'IDTAG', 'Event_ID') VALUES ('Flavia', 'Cestonaro', 'gebtag', '10', 'w', 0, 12435365, 2);");
		});
		mainForm.eventsView.reloadEventsFromDb();
	}

	Header {
		id: header
		anchors.right: parent.right
		anchors.left: parent.left
		anchors.top: parent.top
	}

	Mainform {
		id: mainForm
		db: root.db
		anchors.right: parent.right
		anchors.left: parent.left
		anchors.top: header.bottom
		anchors.bottom: parent.bottom
	}
}
