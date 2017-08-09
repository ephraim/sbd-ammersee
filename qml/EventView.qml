import QtQuick 2.6
import QtQuick.Controls 1.5
import MyCustomClasses 1.0

Rectangle {
	id: root
	property var eventId: -1
	property var startZeit: 0;
	property var endZeit: 0;
	property var activeSwimmer: 0;

	function updateTeilnehmerlist() {
		var rs;
		var teilnehmer = 0;
		teilnehmerView.teilnehmer.clear();
		db.transaction(function(tx) {
			rs = tx.executeSql("Select * from Teilnehmer Where Event_ID == '" + eventId + "' and Endzeit != 0 ORDER BY Endzeit");
			teilnehmer += rs.rows.length;
			if (rs.rows.length > 0) {
				for(var i = 0; i < rs.rows.length; i++)
					teilnehmerView.teilnehmer.append(rs.rows.item(i));
			}
			rs = tx.executeSql("Select * from Teilnehmer Where Event_ID == '" + eventId + "' and Endzeit == 0 ORDER BY Nachname,Vorname");
			teilnehmer += rs.rows.length;
			if (rs.rows.length > 0) {
				activeSwimmer = rs.rows.length;
				for(var i = 0; i < rs.rows.length; i++)
					teilnehmerView.teilnehmer.append(rs.rows.item(i));
			}
		});

		return teilnehmer;
	}

	onEventIdChanged: {
		state = "";
		db.transaction(function(tx) {
			var rs = tx.executeSql("Select * from Event Where ID == '" + eventId + "' LIMIT 1");
			if (rs.rows.length > 0) {
				heading.text = rs.rows.item(0).EventName;
				startZeit = rs.rows.item(0).Startzeit;
				endZeit = rs.rows.item(0).Endzeit;

				if(startZeit != 0) {
					if(endZeit == 0) {
						spc.switchLED(2, true);
						spc.beep();
						spc.onFoundTag.connect(onfoundTag);
						spc.searchTag();
						state = "running";
					}
					else {
						statusText.text = "Beendet nach " + getNeededTime(startZeit, endZeit);
						state = "done";
					}
				}
			}
		});
		;
		if(updateTeilnehmerlist() == 0) {
			showAddTeilnehmerForm();
		}
		else {
			addForm.visible = false;
			teilnehmerView.visible = true;
		}
	}

	function pad(s, size) {
		s = String(s);
		while (s.length < (size || 2)) {s = "0" + s;}
		return s;
	}

	function getNeededTime(start, ende)
	{
		var date = new Date(ende - start);
		return pad(date.getUTCHours(), 2) + ":" + pad(date.getUTCMinutes(), 2) + ":" + pad(date.getUTCSeconds(), 2)
	}

	function formatGebtag(gebtag)
	{
		return Date.fromLocaleDateString(Qt.locale("de_DE"), gebtag, "yyyy-MM-dd").toLocaleDateString(Qt.locale("de_DE"), "dd.MM.yyyy");
	}
	function showAddTeilnehmerForm()
	{
		teilnehmerView.visible = false;
		addForm.clear();
		addForm.visible = true;
	}

	function onfoundTag(result, tagID) {
		if(result) {
			spc.switchLED(1, true);
			spc.beep();
			spc.switchLED(1, false);

			db.transaction(function(tx) {
				var rs = tx.executeSql("Select * from Teilnehmer Where IDTAG == '" + tagID + "' and Event_ID == '" + eventId + "'");
				if (rs.rows.length == 1) {
					var endzeit = Date.now();
					console.log("Teilnehmer " + rs.rows.item(0).Nachname + " " + rs.rows.item(0).Vorname + " was done after: " + getNeededTime(root.startZeit, endzeit));
					tx.executeSql("update Teilnehmer set Endzeit=\"" + endzeit + "\" WHERE IDTAG = \"" + tagID + "\" and Event_ID == '" + eventId + "'");
					updateTeilnehmerlist();
				}
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
		id: statusText
		anchors.top: heading.bottom
		anchors.topMargin: 25
		anchors.horizontalCenter: parent.horizontalCenter
		text: "Schwimmer im Wasser: 0; Zeit: 00:00:00"
		font.pixelSize: 24
		font.weight: Font.Bold
		visible: false
	}

	TeilnehmerListView {
		id: teilnehmerView
		anchors.top: statusText.bottom
		anchors.bottom: button.top
		anchors.topMargin: 10
		anchors.bottomMargin: 10
		anchors.horizontalCenter: parent.horizontalCenter
		width: (parent.width / 3) * 2
		visible: true
	}

	AddTeilnehmerForm {
		id: addForm
		anchors.top: statusText.bottom
		anchors.bottom: button.top
		anchors.topMargin: 10
		anchors.bottomMargin: 10
		anchors.horizontalCenter: parent.horizontalCenter
		width: (parent.width / 3) * 2
		visible: false

		function addTeilnehmerDone() {
			teilnehmerView.visible = true;
			addForm.visible = false;
		}
	}

	Timer {
		id: timer
		interval: 500;
		running: false;
		repeat: true
		onTriggered: {
			var time = getNeededTime(root.startZeit, Date.now());
			statusText.text = "Schwimmer im Wasser: " + activeSwimmer + "; Zeit: " + time;
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
			onClicked: showAddTeilnehmerForm()
			onEntered: parent.color = "#5c8ab5"
			onExited:  parent.color = "#2c5a85"
		}
	}

	FileIOQML {
		id: fileIO
		property var fileName: ""
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
					spc.switchLED(2, true);
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
					spc.onFoundTag.disconnect(onfoundTag);
					spc.switchLED(2, false);
					spc.switchLED(1, true);
					spc.beep();
					spc.beep();
					spc.beep();
					spc.switchLED(1, false);
					root.endZeit = Date.now();
					root.state = "done";
					db.transaction(function(tx) {
						tx.executeSql("update Event set Endzeit=\"" + Date.now() + "\" WHERE ID = \"" + eventId + "\"");
					});
					statusText.text = "Beendet nach " + getNeededTime(root.startZeit, root.endZeit);
				}
				else if(root.state == "done") {
					fileIO.openFileDlg();
					if(fileIO.fileName) {
						fileIO.openFile(fileIO.fileName);
						fileIO.writeLine(heading.text);
						fileIO.writeLine("");
						var line;
						db.transaction(function(tx) {
							var rs = tx.executeSql("SELECT Vorname, Nachname, Gebtag, Endzeit, Visitor FROM Teilnehmer WHERE Event_ID == '" + eventId + "' ORDER BY Endzeit;");
							fileIO.writeLine("Gesamtwertung");
							for(var i = 0; i < rs.rows.length; i++) {
								line = "";
								line += rs.rows.item(i).Vorname + ", ";
								line += rs.rows.item(i).Nachname + ", ";
								line += formatGebtag(rs.rows.item(i).Gebtag) + ", ";
								line += getNeededTime(root.startZeit, rs.rows.item(i).Endzeit) + ", ";
								line += rs.rows.item(i).Visitor ? "Gast" : "Mitglied";
								fileIO.writeLine(line);
							}
							fileIO.writeLine("");

							fileIO.writeLine("Wertung Männer");
							rs = tx.executeSql("SELECT Vorname, Nachname, Gebtag, Endzeit, Visitor FROM Teilnehmer WHERE Event_ID == '" + eventId + "' AND Gender == \"m\" ORDER BY Endzeit;");
							for(var i = 0; i < rs.rows.length; i++) {
								line = "";
								line += rs.rows.item(i).Vorname + ", ";
								line += rs.rows.item(i).Nachname + ", ";
								line += formatGebtag(rs.rows.item(i).Gebtag) + ", ";
								line += getNeededTime(root.startZeit, rs.rows.item(i).Endzeit) + ", ";
								line += rs.rows.item(i).Visitor ? "Gast" : "Mitglied";
								fileIO.writeLine(line);
							}
							fileIO.writeLine("");

							fileIO.writeLine("Wertung Frauen");
							rs = tx.executeSql("SELECT Vorname, Nachname, Gebtag, Endzeit, Visitor FROM Teilnehmer WHERE Event_ID == '" + eventId + "' AND Gender == \"f\" ORDER BY Endzeit;");
							for(var i = 0; i < rs.rows.length; i++) {
								line = "";
								line += rs.rows.item(i).Vorname + ", ";
								line += rs.rows.item(i).Nachname + ", ";
								line += formatGebtag(rs.rows.item(i).Gebtag) + ", ";
								line += getNeededTime(root.startZeit, rs.rows.item(i).Endzeit) + ", ";
								line += rs.rows.item(i).Visitor ? "Gast" : "Mitglied";
								fileIO.writeLine(line);
							}
							fileIO.writeLine("");

							fileIO.writeLine("Männer Jüngster/Ältester");
							rs = tx.executeSql("SELECT Vorname, Nachname, Gebtag, Endzeit, Visitor FROM Teilnehmer WHERE Event_ID == '" + eventId + "' AND Gender == \"m\" ORDER BY Gebtag DESC LIMIT 1;");
							line = "";
							line += rs.rows.item(0).Vorname + ", ";
							line += rs.rows.item(0).Nachname + ", ";
							line += formatGebtag(rs.rows.item(0).Gebtag) + ", ";
							line += getNeededTime(root.startZeit, rs.rows.item(0).Endzeit) + ", ";
							line += rs.rows.item(0).Visitor ? "Gast" : "Mitglied";
							fileIO.writeLine(line);

							rs = tx.executeSql("SELECT Vorname, Nachname, Gebtag, Endzeit, Visitor FROM Teilnehmer WHERE Event_ID == '" + eventId + "' AND Gender == \"m\" ORDER BY Gebtag ASC LIMIT 1;");
							line = "";
							line += rs.rows.item(0).Vorname + ", ";
							line += rs.rows.item(0).Nachname + ", ";
							line += formatGebtag(rs.rows.item(0).Gebtag) + ", ";
							line += getNeededTime(root.startZeit, rs.rows.item(0).Endzeit) + ", ";
							line += rs.rows.item(0).Visitor ? "Gast" : "Mitglied";
							fileIO.writeLine(line);
							fileIO.writeLine("");

							fileIO.writeLine("Frauen Jüngste/Älteste");
							rs = tx.executeSql("SELECT Vorname, Nachname, Gebtag, Endzeit, Visitor FROM Teilnehmer WHERE Event_ID == '" + eventId + "' AND Gender == \"f\" ORDER BY Gebtag DESC LIMIT 1;");
							line = "";
							line += rs.rows.item(0).Vorname + ", ";
							line += rs.rows.item(0).Nachname + ", ";
							line += formatGebtag(rs.rows.item(0).Gebtag) + ", ";
							line += getNeededTime(root.startZeit, rs.rows.item(0).Endzeit) + ", ";
							line += rs.rows.item(0).Visitor ? "Gast" : "Mitglied";
							fileIO.writeLine(line);

							rs = tx.executeSql("SELECT Vorname, Nachname, Gebtag, Endzeit, Visitor FROM Teilnehmer WHERE Event_ID == '" + eventId + "' AND Gender == \"f\" ORDER BY Gebtag ASC LIMIT 1;");
							line = "";
							line += rs.rows.item(0).Vorname + ", ";
							line += rs.rows.item(0).Nachname + ", ";
							line += formatGebtag(rs.rows.item(0).Gebtag) + ", ";
							line += getNeededTime(root.startZeit, rs.rows.item(0).Endzeit) + ", ";
							line += rs.rows.item(0).Visitor ? "Gast" : "Mitglied";
							fileIO.writeLine(line);
							fileIO.writeLine("");
						});
						fileIO.closeFile();
					}
				}
			}
			onEntered: {
				parent.color = "#5c8ab5";
			}
			onExited:  parent.color = "#2c5a85"
		}
	}

	states: [
		State {
			name: "running"
			PropertyChanges { target: btnLabel;			text: "Stop" }
			PropertyChanges { target: statusText;			visible: true }
			PropertyChanges { target: timer;			running: true }
			PropertyChanges { target: addTeilnehmer;	visible: false }
		},
		State {
			name: "done"
			PropertyChanges { target: btnLabel;			text: "Export" }
			PropertyChanges { target: statusText;			visible: true }
			PropertyChanges { target: timer;			running: false }
			PropertyChanges { target: addTeilnehmer;	visible: false }
		}
	]
}
