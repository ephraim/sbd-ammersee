import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	function reloadEventsFromDb(eventname) {
		var current = 0;
		db.transaction(function(tx) {
			events.clear();
			var rs = tx.executeSql("SELECT * FROM Event ORDER BY EventName");
			for(var i = 0; i < rs.rows.length; i++) {
				if(eventname == rs.rows.item(i).EventName)
					current = events.count;
				events.append({ eventid: rs.rows.item(i).ID, name: rs.rows.item(i).EventName, startZeit: rs.rows.item(i).Startzeit });
			}
		});
		if(events.count > 0) {
			eventsList.currentIndex = current;
			openEvent(events.get(eventsList.currentIndex).eventid);
		}
		else {
			showAddEvent();
		}
	}

	ListModel {
		id: events
	}

	ListView {
		id: eventsList
		spacing: 2
		clip: true
		anchors.fill: parent
		anchors.rightMargin: 5
		model: events
		delegate: Component {
			Item {
				id: delegate
				anchors.left: parent.left
				anchors.right: parent.right
				height: 27

				Rectangle {
					id: hoverHighlight
					anchors.fill: parent
					radius: 5
					color: "#5c8ab5"
					state: "invisible"
					states: [
						State {
							name: "visible"
							PropertyChanges { target: hoverHighlight; opacity: 1.0  }
							PropertyChanges { target: hoverHighlight; visible: true }
						},
						State {
							name: "invisible"
							PropertyChanges { target: hoverHighlight; opacity: 0  }
							PropertyChanges { target: hoverHighlight; visible: false }
						}
					]
					transitions: [
						Transition {
							from: "visible"
							to: "invisible"
							SequentialAnimation {
								NumberAnimation {
									target: hoverHighlight
									property: "opacity"
									duration: 1000
									easing.type: Easing.InOutQuad
								}
								NumberAnimation {
									target: hoverHighlight
									property: "visible"
									duration: 0
								}
							}
						}
					]
				}

				Text {
					id: delegateContent
					anchors.fill: parent
					anchors.leftMargin: 5
					anchors.rightMargin: 5
					text: name.length > 10 ? name.substr(0, 3) + " .. " + name.substr(-3) : name
					font.pixelSize: 24
					color: delegate.ListView.isCurrentItem ? "white" : ""
				}

				Item {
					id: deleteEvent
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.topMargin: 2
					anchors.bottomMargin: 2
					visible: false
					width: 25
					height: parent.height
					opacity: 0.5
					Text {
						id: theEventX
						anchors.centerIn: parent
						text: "X"
						font.pixelSize: 16
						color: "white"
					}
				}

				MouseArea {
					hoverEnabled: true
					anchors.fill: parent
					onClicked: {
						if(eventsList.currentItem)
							eventsList.currentItem.children[1].color = "";
						eventsList.currentIndex = index;
						delegateContent.color   = "white";
						hoverHighlight.state    = "invisible";
						deleteEvent.visible		= (startZeit == 0);
						openEvent(eventid);
					}
					onEntered: {
						if(!delegate.ListView.isCurrentItem) {
							delegateContent.color  = "white";
							hoverHighlight.state   = "visible";
						}
						else
							deleteEvent.visible = (startZeit == 0);
					}
					onExited: {
						if(!delegate.ListView.isCurrentItem) {
							delegateContent.color  = "";
							hoverHighlight.state   = "";
							hoverHighlight.state   = "invisible";
						}

						deleteEvent.visible = false;
					}
				}

				MouseArea {
					hoverEnabled: true
					anchors.fill: deleteEvent
					onClicked: {
						if(startZeit == 0) {
							db.transaction(function(tx) {
								tx.executeSql("Delete from Event Where ID == '" + eventid + "' LIMIT 1;");
								tx.executeSql("Delete from Teilnehmer Where Event_ID == '" + eventid + "'");
							});
							reloadEventsFromDb();
						}
					}
					onEntered: { deleteEvent.visible = (startZeit == 0); theEventX.color = "red"; }
					onExited: { theEventX.color = "white"; }
				}				
			}
		}
		highlight: Component {
			Rectangle {
				width: eventsList.currentItem ? eventsList.currentItem.width : 0
				height: eventsList.currentItem ? eventsList.currentItem.height : 0
				color: "#2c5a85"
				radius: 5
				y: eventsList.currentItem ? eventsList.currentItem.y : 0
				Behavior on y {
					SmoothedAnimation {
						duration: 1000
					}
				}				
			}
		}
		highlightFollowsCurrentItem: false
		focus: true
		headerPositioning: ListView.OverlayHeader
		header: Component {
			Text {
				height: 50
				text: "Events"
				font.pixelSize: 24
				font.weight: Font.Bold
			}
		}
	}
	Rectangle {
		height: 50
		anchors.bottom: eventsList.bottom
		anchors.right: eventsList.right
		Rectangle {
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			color: "#2c5a85"
			height: 30
			radius: 5
			width: 50
			Text {
				anchors.centerIn: parent
				text: "+"
				font.pixelSize: 20
				color: "white"
			}
			MouseArea {
				hoverEnabled: true
				anchors.fill: parent
				onClicked: {
					if(eventsList.currentItem) {
						eventsList.currentItem.children[1].color = ""
						eventsList.currentIndex = -1;
					}
					showAddEvent();
				}
				onEntered: parent.color = "#5c8ab5"
				onExited: parent.color = "#2c5a85"
			}
		}
	}
}
