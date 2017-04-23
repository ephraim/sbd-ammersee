import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	id: root
	property var eventId: -1
	property var startZeit: 0;
	property var endZeit: 0;

	onEventIdChanged: {
		teilnehmerView.teilnehmer.clear();
		state = "";
		db.transaction(function(tx) {
			var rs = tx.executeSql("Select * from Event Where ID == '" + eventId + "' LIMIT 1");
			if (rs.rows.length > 0) {
				heading.text = rs.rows.item(0).EventName;
				startZeit = rs.rows.item(0).Startzeit;
				endZeit = rs.rows.item(0).Endzeit;

				if(startZeit != 0)
					state = endZeit == 0 ? "running" : "done";

				rs = tx.executeSql("Select * from Teilnehmer Where Event_ID == '" + eventId + "'");
				if (rs.rows.length > 0) {
					for(var i = 0; i < rs.rows.length; i++)
						teilnehmerView.teilnehmer.append(rs.rows.item(i));
				}
			}
		});
	}

	function onfoundTag(result, tagID) {
		if(result) {
			spc.switchLED(0x01, true);
			spc.beep();
			spc.switchLED(0x01, false);
			db.transaction(function(tx) {
				tx.executeSql("update Teilnehmer set Endzeit=\"" + Date.now() + "\" WHERE IDTAG = \"" + tagID + "\"");
			});
		}
		spc.searchTag();
	}

	Text {
		id: heading
		anchors.topMargin: 50
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter
		text: ""
		font.pixelSize: 32
		font.weight: Font.Bold
	}

	Text {
		id: timeView
		anchors.top: heading.bottom
		anchors.topMargin: 25
		anchors.horizontalCenter: parent.horizontalCenter
		text: "00:00:00"
		font.pixelSize: 24
		font.weight: Font.Bold
		visible: false
	}

	TeilnehmerListView {
		id: teilnehmerView
		anchors.top: timeView.bottom
		anchors.bottom: button.top
		anchors.topMargin: 10
		anchors.bottomMargin: 10
		anchors.horizontalCenter: parent.horizontalCenter
		width: (parent.width / 3) * 2
		visible: true
	}

	AddTeilnehmerForm {
		id: addForm
		anchors.top: timeView.bottom
		anchors.bottom: button.top
		anchors.topMargin: 10
		anchors.bottomMargin: 10
		anchors.horizontalCenter: parent.horizontalCenter
		width: (parent.width / 3) * 2
		visible: false
	}

	Timer {
		id: timer
		interval: 500;
		running: false;
		repeat: true
		onTriggered: {
			var tmp = new Date(Date.now() - root.startZeit);
			timeView.text = "%02d:%02d:%02d".format(tmp.getHours(), tmp.getMinutes(), tmp.getSeconds());
		}
	}

	Rectangle {
		id: addTeilnehmer
		anchors.right: teilnehmerView.right
		anchors.bottom: teilnehmerView.bottom
		color: "#2c5a85"
		height: 30
		radius: 5
		width: 50
		visible: true
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
				teilnehmerView.visible = false;
				addForm.visible = true;
			}
			onEntered: parent.color = "#5c8ab5"
			onExited:  parent.color = "#2c5a85"
		}
	}

	Rectangle {
		id: button
		anchors.right: teilnehmerView.right
		anchors.bottom: root.bottom
		anchors.bottomMargin: 5
		color: "#2c5a85"
		height: 30
		radius: 5
		width: btnLabel.width + 20
		visible: true
		Text {
			id: btnLabel
			anchors.centerIn: parent
			text: "Start"
			font.pixelSize: 20
			color: "white"
		}
		MouseArea {
			hoverEnabled: true
			anchors.fill: parent
			onClicked: {
				if(root.state == "") {
					spc.switchLED(0x02, true);
					spc.beep();
					spc.onFoundTag.connect(onfoundTag);
					spc.searchTag();
					root.startZeit = Date.now();
					root.state = "running";
					db.transaction(function(tx) {
						tx.executeSql("update Event set Startzeit=\"" + root.startZeit + "\" WHERE ID = \"" + eventId + "\"");
					});
				}
				else if(root.state == "running") {
					root.state = "done";
					spc.onFoundTag.disconnect(onfoundTag);
					db.transaction(function(tx) {
						tx.executeSql("update Event set Endzeit=\"" + Date.now() + "\" WHERE ID = \"" + eventId + "\"");
					});
				}
			}
			onEntered: parent.color = "#5c8ab5"
			onExited:  parent.color = "#2c5a85"
		}
	}

	states: [
		State {
			name: "running"
			PropertyChanges { target: btnLabel;	text: "Stop"	 }
			PropertyChanges { target: timeView;	visible: true	 }
			PropertyChanges { target: timer;	running: true	 }
		},
		State {
			name: "done"
			PropertyChanges { target: button;	visible: false }
			PropertyChanges { target: timeView;	text: "Beendet"; visible: true }
			PropertyChanges { target: timer;	running: false }
		}
	]
}
