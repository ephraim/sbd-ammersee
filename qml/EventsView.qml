import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	property var mainForm

	function reloadEventsFromDb() {
		mainForm.db.transaction(function(tx) {
			events.clear();
			var rs = tx.executeSql("SELECT * FROM Event ORDER BY EventName");
			for(var i = 0; i < rs.rows.length; i++) {
				events.append({ id: rs.rows.item(i).ID, name: rs.rows.item(i).EventName });
			}
		});
	}

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
			Button {
				anchors.right: parent.right
				anchors.rightMargin: 5
				text: "+"
				width: 25
				onClicked: showAddEvent()
			}
		}
	}
}
