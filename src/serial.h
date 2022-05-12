#ifndef _WIN32
#include <termios.h>
#include <mutex>
#else
#define O_NOCTTY 0
#endif
#ifdef __GNUC__
#include <unistd.h>
#endif
#include <QSerialPort>
#include <stdint.h>
#include <vector>
#include <string>
#include <mutex>

using namespace std;

class Serial {
public:
	Serial(string port, int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
	virtual ~Serial();

	bool setParameters(int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
	vector<uint8_t> write_read(vector<uint8_t> v);
	uint16_t genCrc(vector<uint8_t> v);
    bool isOpen();

protected:
	int write(const vector<uint8_t> &v);
	vector<uint8_t> read();

	std::mutex write_read_mutex;
private:
#ifdef _WIN32
    QSerialPort serialport;
    int timeout;
#else
	int fd;
#endif
};
