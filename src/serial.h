#include <termios.h>
#include <unistd.h>
#include <stdint.h>
#include <vector>
#include <string>

using namespace std;

class Serial {
public:
	Serial(string port = "/dev/ttyACM0", int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
	virtual ~Serial();

	bool setParameters(int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
	vector<uint8_t> write_read(vector<uint8_t> v);
	int write(const vector<uint8_t> &v);
	vector<uint8_t> read();
	uint16_t genCrc(vector<uint8_t> v);
	bool isOpen() { return fd >= 0; }

private:
	int fd;
};