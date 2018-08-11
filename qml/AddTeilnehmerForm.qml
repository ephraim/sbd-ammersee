import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	id: root
	property var formwidth: 400
	property var rowheight: 24
	property var teilnehmerID: -1

	function pad(s, size) {
		s = String(s);
		while (s.length < (size || 2)) {s = "0" + s;}
		return s;
	}

	function formatGebtagForDB(gebtag)
	{
		var date = Date.fromLocaleDateString(Qt.locale("de_DE"), gebtag, "dd.MM.yyyy");
		return date.getFullYear() + "-" + pad(date.getMonth()+1, 2) + "-" + pad(date.getDate(), 2);
	}

	function clear(teilnehmer) {
		if(teilnehmer == null) {
			startnummer.entry = 1;
			db.transaction(function(tx) {
				var rs = tx.executeSql("select Startnr from Teilnehmer Where Event_ID == '" + eventId + "' Order By Startnr Desc Limit 1")
				if(rs.rows.length == 1)
					startnummer.entry = rs.rows.item(0).Startnr + 1;
			});
			vorname.entry = "";
			nachname.entry = "";
			geburtstag.entry = "";
			rbGenderMale.checked = true;
			rbGenderFemale.checked = false;
			cbVisitor.checked = false;
			tagId.text = "";
			teilnehmerID = -1;
		}
		else {
			startnummer.entry = teilnehmer.Startnr;
			vorname.entry = teilnehmer.Vorname;
			nachname.entry = teilnehmer.Nachname;
			geburtstag.entry = formatGebtagForUser(teilnehmer.Gebtag);
			rbGenderMale.checked = teilnehmer.Gender == "m";
			rbGenderFemale.checked = teilnehmer.Gender != "m";
			cbVisitor.checked = teilnehmer.Visitor != 0;
			tagId.text = teilnehmer.IDTAG;
			teilnehmerID = teilnehmer.ID;
		}
	}

	function onFoundTeilnehmerTag(result, tagID) {
		if(result) {
			tagId.text = tagID;
			spc.beep();
		}
		else {
			tagId.text = "";
			spc.switchLED(0x01, true);
			spc.beep();
			spc.beep();
			spc.switchLED(0x01, false);
		}
		spc.switchLED(0x02, false);
		spc.onFoundTag.disconnect(onFoundTeilnehmerTag);
	}

	Text {
		id: heading
		anchors.topMargin: 30
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter
		text: "Teilnehmer hinzufügen"
		font.pixelSize: 32
		font.weight: Font.Bold
	}

	FormEntry {
		id: vorname
		anchors.topMargin: 50
		anchors.top: heading.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		label: "Vorname:"
		entry: "Thilo"
	}

	FormEntry {
		id: nachname
		anchors.topMargin: 10
		anchors.top: vorname.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		label: "Nachname:"
		entry: "Cestonaro"
	}
	FormEntry {
		id: geburtstag
		anchors.topMargin: 10
		anchors.top: nachname.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		label: "Geburtstag:"
		entry: "28.04.1977"
	}
	FormEntry {
		id: startnummer
		anchors.topMargin: 10
		anchors.top: geburtstag.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		label: "Startnummer:"
		entry: "42"
	}
	Row {
		id: gender
		anchors.topMargin: 10
		anchors.top: startnummer.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		spacing: 2
		Text {
			id: lblGender
			width: parent.width / 4
			height: parent.height
			text: "Geschlecht:"
		}
		ExclusiveGroup { id: grpGender }
		RadioButton {
			id: rbGenderMale
			width: ((parent.width / 4) * 3) / 2
			text: "Männlich"
			checked: true
			exclusiveGroup: grpGender
		}
		RadioButton {
			id: rbGenderFemale
			width: ((parent.width / 4) * 3) / 2
			text: "Weiblich"
			exclusiveGroup: grpGender
		}
	}
	Row {
		id: visitor
		anchors.topMargin: 10
		anchors.top: gender.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		spacing: 2
		Text {
			id: lblVisitor
			width: parent.width / 4
			height: parent.height
			text: "Besucher:"
		}
		CheckBox {
			id: cbVisitor
		}
	}
	Row {
		id: tagEntry
		anchors.topMargin: 10
		anchors.top: visitor.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		height: root.rowheight
		width: root.formwidth
		spacing: 2
		Text {
			width: parent.width / 4
			height: parent.height
			text: "TagID:"
		}
		TextField {
			id: tagId
			width: ((parent.width / 4) * 3) - 50
			height: parent.height
			verticalAlignment: TextEdit.AlignVCenter
		}
		Button {
			id: btnSearchTag
			width: 50
			height: parent.height
			text: "..."
			onClicked: function() {
				var tagId;
				spc.switchLED(0x02, true);
				spc.beep();
				spc.onFoundTag.connect(onFoundTeilnehmerTag);
				spc.searchTag();
			}
		}
	}
	Row {
		anchors.topMargin: 10
		anchors.top: tagEntry.bottom
		width: root.formWidth
		height: root.rowheight
		anchors.horizontalCenter: parent.horizontalCenter
		Button {
			id: btnSubmit
			text: teilnehmerID == -1 ? "Hinzufügen" : "Ändern"
			onClicked: {
				var gebtag = formatGebtagForDB(geburtstag.entry);
				db.transaction(function(tx) {
					if(teilnehmerID == -1) {
						var query = "INSERT INTO Teilnehmer ('Vorname', 'Nachname', 'Gebtag', 'Startnr', 'Gender', 'Visitor', 'IDTAG', 'Event_ID') VALUES (";
						query += "'" + vorname.entry + "',";
						query += "'" + nachname.entry + "',";
						query += "'" + gebtag + "',";
						query += "'" + startnummer.entry + "',";
						query += "'" + (rbGenderMale.checked ? "m" : "f") + "',";
						query += "'" + (cbVisitor.checked ? 1 : 0) + "',";
						query += "'" + tagId.text + "',";
						query += "'" + eventId + "');";
					}
					else {
						var query = "UPDATE Teilnehmer SET ";
						query += "Vorname='" + vorname.entry + "',";
						query += "Nachname='" + nachname.entry + "',";
						query += "Gebtag='" + gebtag + "',";
						query += "Startnr='" + startnummer.entry + "',";
						query += "Gender='" + (rbGenderMale.checked ? "m" : "f") + "',";
						query += "Visitor='" + (cbVisitor.checked ? 1 : 0) + "',";
						query += "IDTAG='" + tagId.text + "'";
						query += "WHERE ID = '" + teilnehmerID + "'";
					}
					var rs = tx.executeSql(query);
				});
				openEvent(eventId);
				addTeilnehmerDone();
			}
		}
	}
}
