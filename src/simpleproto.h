#include <string>
#include <vector>

#ifndef __SIMPLE_PROTO_H__
#define __SIMPLE_PROTO_H__

#include "serial.h"

using namespace std;

enum SPC_LED {
	SPC_LED_RED		= 0x01,
	SPC_LED_GREEN	= 0x02,
	SPC_LED_YELLOW	= 0x04
};

class SimpleProtocolClient : public Serial
{
public:
	SimpleProtocolClient(string port = "/dev/ttyACM0");
	virtual ~SimpleProtocolClient();

	virtual void beep(uint8_t volume = 85, uint16_t frequence = 2000, uint16_t ontime = 0x80, uint16_t offtime = 0x80);
	virtual void diagLEDToggle();
	virtual void switchLED(enum SPC_LED led, bool on);
	virtual void blinkLED(enum SPC_LED led, uint16_t timeHI = 0x64, uint16_t timeLO = 0x64);
	virtual void getTagTypes(uint32_t &lfTagTypes, uint32_t &hiTagTypes);
	virtual void setTagTypes(uint32_t lfTagTypes, uint32_t hiTagTypes);
	virtual bool searchTag(vector<uint8_t>& tagID);
protected:
	void GPIOConfigureOutputs(uint8_t GPOs, uint8_t PullUpDown, uint8_t OutputType);
};
#endif
