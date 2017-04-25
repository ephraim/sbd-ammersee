import QtQuick 2.6
import QtQuick.Layouts 1.3

Flickable {
	property alias teilnehmer: teilnehmer

	ListModel {
		id: teilnehmer
	}

	ListView {
		id: theList
		spacing: 2
		clip: true
		anchors.topMargin: 5
		anchors.bottomMargin: 5
		anchors.fill: parent
		model: teilnehmer
		delegate: Component {
			id: delegateTeilnehmer
			Rectangle {
				radius: 5
				height: 50
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 5
				anchors.rightMargin: 5
				width: parent.width
				color: Visitor ? "lightgrey" : "#5c8ab5"
				Row {
					id: mainInfo
					spacing: 5
					Text {
						text: Startnr
						font.pixelSize: 24
					}
					Text {
						text: Nachname + " " + Vorname
						font.pixelSize: 24
					}
				}
				Row {
					anchors.top: mainInfo.bottom
					anchors.topMargin: 5
					anchors.left: parent.left
					anchors.leftMargin: 35
					spacing: 5
					Text {
						text: Gender == "m" ? "männlich" : "weiblich"
						font.pixelSize: 12
					}
					Text {
						text: Gebtag
						font.pixelSize: 12
					}
				}
				Item {
					id: deleteTeilnehmer
					anchors.right: parent.right
					anchors.top: parent.top
					visible: false
					width: 25
					height: 25
					opacity: 0.5
					Text {
						id: theX
						anchors.centerIn: parent
						text: "X"
						font.pixelSize: 20
						color: "white"
					}
				}
				MouseArea {
					hoverEnabled: true
					anchors.fill: parent
					onClicked: { console.log("big mousearea clicked"); }
					onEntered: { deleteTeilnehmer.visible = true; }
					onExited: { deleteTeilnehmer.visible = false; }
				}
				MouseArea {
					hoverEnabled: true
					anchors.fill: deleteTeilnehmer
					onClicked: {
						db.transaction(function(tx) {
							tx.executeSql("Delete from Teilnehmer where ID == '" + ID + "' LIMIT 1;");
						});
						openEvent(eventId);
					}
					onEntered: { theX.color = "red"; deleteTeilnehmer.visible = true; }
					onExited: { theX.color = "white"; deleteTeilnehmer.visible = false; }
				}
			}
		}
	}
}
