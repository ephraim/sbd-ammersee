import QtQuick 2.6
import QtQuick.Layouts 1.3

Flickable {
	property alias teilnehmer: teilnehmer
	property var eventStartzeit: 0

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
				Column {
					id: leftColumn
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.topMargin: 5
					anchors.leftMargin: 5
					width: parent.width / 3 - 10
					Row {
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
				}
				Column {
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.left: leftColumn.right
					anchors.topMargin: 5
					anchors.bottomMargin: 5
					anchors.leftMargin: 5
					width: parent.width / 3 * 2 - 10
					Row {
						spacing: 5
						Text {
							id: neededTime
							text: Endzeit != 0 ? getNeededTime(startZeit, Endzeit) : ""
							font.pixelSize: 32
						}
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
