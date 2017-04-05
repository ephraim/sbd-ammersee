import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	id: root
	property var mainForm

	Text {
		id: heading
		anchors.topMargin: 50
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter
		text: "Event hinzufügen"
		font.pixelSize: 32
	}

	Row {
		id: entry
		anchors.topMargin: 100
		anchors.top: heading.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: 24
		spacing: 2
		Rectangle {
			width: 100
			height: parent.height
			Text {
				anchors.verticalCenter: parent.verticalCenter
				text: "Event Name:"
			}
		}
		TextField {
			id: eventName
			width: 300
			height: parent.height
			verticalAlignment: TextEdit.AlignVCenter
			anchors.verticalCenter: parent.verticalCenter
		}
	}
	Row {
		anchors.topMargin: 10
		anchors.top: entry.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		width: entry.width
		height: entry.height
		Button {
			anchors.right: parent.right
			text: "add"
			onClicked: function() {
				mainForm.db.transaction(function(tx){
					tx.executeSql("INSERT INTO 'Event' ('EventName') VALUES ('" + eventName.text + "')");
				});
				mainForm.eventsView.reloadEventsFromDb();
			}
		}
	}
}
