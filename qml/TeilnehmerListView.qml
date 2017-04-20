import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	property alias teilnehmer: teilnehmer

	ListModel {
		id: teilnehmer
	}

	ListView {
		spacing: 2
		clip: true
		anchors.topMargin: 5
		anchors.bottomMargin: 5
		anchors.fill: parent
		model: teilnehmer
		delegate: Component {
			id: delegateTeilnehmer
			Rectangle {
				height: 45
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 5
				anchors.rightMargin: 5
				width: parent.width
				Text {
					id: name
					text: Nachname + " " + Vorname
					font.pixelSize: 24
				}
				Text {
					anchors.top: name.bottom
					text: Gender == "m" ? "männlich" : "weiblich"
					font.pixelSize: 12
				}
			}
		}
	}
}
