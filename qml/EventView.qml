import QtQuick 2.6
import QtQuick.Controls 1.5

Rectangle {
	property var eventId: -1

	onEventIdChanged: {
		teilnehmerView.teilnehmer.clear();

		db.transaction(function(tx) {
			var rs = tx.executeSql("Select EventName from Event Where ID == '" + eventId + "'");
			if (rs.rows.length == 1)
				heading.text = rs.rows.item(0).EventName;

			rs = tx.executeSql("Select * from Teilnehmer Where Event_ID == '" + eventId + "'");
			if (rs.rows.length > 0) {
				for(var i = 0; i < rs.rows.length; i++)
					teilnehmerView.teilnehmer.append(rs.rows.item(i));
			}
		});
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

	TeilnehmerListView {
		id: teilnehmerView
		anchors.right: parent.right
		anchors.rightMargin: 5
		anchors.top: heading.bottom
		anchors.topMargin: 10
		anchors.bottom: parent.bottom
		width: (parent.width / 3) * 2
	}
}
