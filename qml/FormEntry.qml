import QtQuick 2.6
import QtQuick.Controls 1.5

Row {
	id: root
	property alias label: lbl.text
	property alias entry: txt.text

	spacing: 2

	Text {
		id: lbl
		width: parent.width / 4
		height: parent.height
	}
	TextField {
		id: txt
		width: (parent.width / 4) * 3
		height: parent.height
		verticalAlignment: TextEdit.AlignVCenter
		anchors.verticalCenter: parent.verticalCenter
	}
}
