import QtQuick 2.6
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQml.Models 2.2
import QtQuick.LocalStorage 2.0

Item {
	id: root
	property var db
	property alias eventsView: eventsView

	function openEvent(id) {
		content.state = "";
		eventView.eventId = id;
	}

	function showAddEvent() {
		content.state = "addEvent";
	}

	function hideAddEvent() {
		content.state = "";
	}

	Rectangle {
		anchors.fill: parent
		color: "#2c5a85"

		Rectangle {
			id: content
			width: parent.width / 100 * 75
			color: "#ffffff"
			anchors.top: parent.top
			anchors.topMargin: 50
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 25
			anchors.horizontalCenter: parent.horizontalCenter
			radius: 5

			EventsView {
				id: eventsView
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				anchors.margins: 10
				width: 150
			}

			Rectangle {
				id: seperator
				color: "#2c5a85"
				width: 4
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.left: eventsView.right
			}

			EventView {
				id: eventView
				anchors.top: parent.top
				anchors.leftMargin: 5
				anchors.left: seperator.right
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				anchors.margins: 10
			}

			AddEventForm {
				id: addEventForm
				anchors.top: parent.top
				anchors.leftMargin: 5
				anchors.left: eventsView.right
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				anchors.margins: 10
				visible: false
			}

			states: [
				State {
					name: "addEvent"
					PropertyChanges { target: eventView;	visible: false }
					PropertyChanges { target: addEventForm;	visible: true }
				}
			]
		}
	}
}
