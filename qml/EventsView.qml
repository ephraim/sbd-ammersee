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
		headerPositioning: ListView.OverlayHeader
		header: Component {
			Rectangle {
				height: text01.height + 2
				anchors.left: parent.left
				anchors.right: parent.right
				Text {
					id: text01
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					text: "Events"
					font.pixelSize: 24
					font.weight: Font.Bold
				}
				Rectangle {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					height: 2
					border.width: 1
				}
			}
		}
		footerPositioning: ListView.OverlayFooter
		footer: Component {
			Rectangle {
				height: btn01.height + 2
				anchors.left: parent.left
				anchors.right: parent.right
				Rectangle {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					height: 2
					border.width: 1
				}
				Button {
					id: btn01
					anchors.right: parent.right
					anchors.rightMargin: 5
					anchors.bottom: parent.bottom
					text: "+"
					width: 25
					onClicked: showAddEvent()
				}
			}
		}
	}
}
