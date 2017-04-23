import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	id: root
	property var mainForm

	Component.onCompleted: {
		/*spc.onFoundTag.connect(function(result, tagID) {
			if(result) {
				eventTag.text = tagID;
				spc.beep();
			}
			else {
				eventTag.text = "";
				spc.switchLED(0x01, true);
				spc.beep();
				spc.beep();
				spc.switchLED(0x01, false);
			}
			spc.switchLED(0x02, false);
		});*/
	}
	Text {
		id: heading
		anchors.topMargin: 50
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter
		text: "Event hinzufügen"
		font.pixelSize: 32
		font.weight: Font.Bold
	}

	Row {
		id: nameEntry
		anchors.topMargin: 100
		anchors.top: heading.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: 24
		spacing: 2
		width: 400
		Text {
			width: 100
			height: parent.height
			text: "Event Name:"
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
		id: tagEntry
		anchors.topMargin: 10
		anchors.top: nameEntry.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		width: nameEntry.width
		height: nameEntry.height
		spacing: 2
		Text {
			width: 100
			height: parent.height
			text: "TagID:"
		}
		TextField {
			id: eventTag
			width: eventName.width - btnSearchTag.width
			height: parent.height
			verticalAlignment: TextEdit.AlignVCenter
		}
		Button {
			id: btnSearchTag
			width: 50
			height: parent.height
			text: "..."
			onClicked: function() {
				var tagId;
				spc.switchLED(0x02, true);
				spc.beep();
				spc.searchTag();
			}
		}
	}
	Row {
		anchors.topMargin: 10
		anchors.top: tagEntry.bottom
		width: nameEntry.width
		height: nameEntry.height
		anchors.horizontalCenter: parent.horizontalCenter
		Button {
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
