import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	id: root
	property var formwidth: 400
	property var rowheight: 24
	property alias eventname: event.entry

	Text {
		id: heading
		anchors.topMargin: 50
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter
		text: "Event hinzufügen"
		font.pixelSize: 32
		font.weight: Font.Bold
	}

	FormEntry {
		id: event
		anchors.topMargin: 30
		anchors.top: heading.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		label: "Name:"
	}
	Row {
		anchors.topMargin: 10
		anchors.top: event.bottom
		width: root.formWidth
		height: root.rowheight
		anchors.horizontalCenter: parent.horizontalCenter
		Button {
			text: "Hinzufügen"
			onClicked: function() {
				db.transaction(function(tx){
					tx.executeSql("INSERT INTO 'Event' ('EventName') VALUES ('" + event.entry + "')");
				});
				eventsView.reloadEventsFromDb(event.entry);
				hideAddEvent();
			}
		}
	}
}
