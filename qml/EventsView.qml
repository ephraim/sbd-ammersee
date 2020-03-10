import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
    id: listParent
    property alias currentIndex: eventsList.currentIndex
    property alias events: events

    function reloadEventsFromDb(eventname) {
		var current = 0;
		db.transaction(function(tx) {
			events.clear();
			var rs = tx.executeSql("SELECT * FROM Event ORDER BY EventName");
			for(var i = 0; i < rs.rows.length; i++) {
                if(eventname === rs.rows.item(i).EventName)
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

				MouseArea {
					hoverEnabled: true
					anchors.fill: parent
					onClicked: {
						if(eventsList.currentItem)
							eventsList.currentItem.children[1].color = "";
						eventsList.currentIndex = index;
						delegateContent.color   = "white";
						hoverHighlight.state    = "invisible";
						openEvent(eventid);
					}
					onEntered: {
						if(!delegate.ListView.isCurrentItem) {
							delegateContent.color  = "white";
							hoverHighlight.state   = "visible";
						}
					}
					onExited: {
						if(!delegate.ListView.isCurrentItem) {
							delegateContent.color  = "";
							hoverHighlight.state   = "";
							hoverHighlight.state   = "invisible";
						}
					}
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
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 55
            color: "#2c5a85"
            height: 30
            radius: 5
            width: 50
            Text {
                anchors.centerIn: parent
                text: "-"
                font.pixelSize: 20
                color: "white"
            }
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                onClicked: {
                    if(eventsList.currentItem) {
                        var eventName = events.get(eventsList.currentIndex).name
                        deleteEventDlg.text = "Willst du wirklich das Event \"" + eventName + "\" löschen?"
                        deleteEventDlg.visible = true
                    }
                }
                onEntered: parent.color = "#5c8ab5"
                onExited: parent.color = "#2c5a85"
            }
        }

        Rectangle {
            color: "#2c5a85"
            height: 30
            radius: 5
            width: 50
            anchors.bottom: parent.bottom
            anchors.right: parent.right
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
