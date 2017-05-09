#include "simpleproto.h"
#include "misc.h"
#include <QObject>
#include <QtConcurrent>

class QSimpleProtocolClient : public QObject, public SimpleProtocolClient
{
	Q_OBJECT
public:
	QSimpleProtocolClient(QString port = "/dev/ttyACM0") : SimpleProtocolClient(port.toStdString()) { };
public slots:
	void beep(uint8_t volume = 85, uint16_t frequence = 2000, uint16_t ontime = 0x80, uint16_t offtime = 0x80) {
		SimpleProtocolClient::beep(volume, frequence, ontime, offtime);
	}
	void switchLED(int led, bool on) {
		SimpleProtocolClient::switchLED((enum SPC_LED)led, on);
	}
	void blinkLED(int led, uint16_t timeHI = 0x64, uint16_t timeLO = 0x64) {
		SimpleProtocolClient::blinkLED((enum SPC_LED)led, timeHI, timeLO);
	}
	void getTagTypes(uint32_t &lfTagTypes, uint32_t &hiTagTypes) {
		SimpleProtocolClient::getTagTypes(lfTagTypes, hiTagTypes);
	}
	void setTagTypes(uint32_t lfTagTypes, uint32_t hiTagTypes) {
		SimpleProtocolClient::setTagTypes(lfTagTypes, hiTagTypes);
	}
	void searchTag() {
		QtConcurrent::run(this, &QSimpleProtocolClient::_searchTag);
	}
protected:
	void _searchTag() {
		std::vector<uint8_t> v;
		if(SimpleProtocolClient::searchTag(v)) {
			emit foundTag(true, QString().fromStdString(b2h(v)));
			return;
		}
		emit foundTag(false, QString());
	}
signals:
	void foundTag(bool result, QString tagID);
};
