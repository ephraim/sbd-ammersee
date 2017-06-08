#ifndef _WIN32
#include <termios.h>
#include <mutex>
#else
#define O_NOCTTY 0
#endif
#include <unistd.h>
#include <stdint.h>
#include <vector>
#include <string>

using namespace std;

class Serial {
public:
#ifndef _WIN32
	Serial(string port, int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
#else
	Serial(string port);
#endif
	virtual ~Serial();

#ifndef _WIN32
	bool setParameters(int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
#else
	bool setParameters();
#endif
	vector<uint8_t> write_read(vector<uint8_t> v);
	uint16_t genCrc(vector<uint8_t> v);
	bool isOpen() { return fd >= 0; }

protected:
	int write(const vector<uint8_t> &v);
	vector<uint8_t> read();
#ifndef _WIN32
	std::mutex write_read_mutex;
#endif
private:
	int fd;
};
