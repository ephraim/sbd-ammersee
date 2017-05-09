#ifdef _WIN32
#define O_NOCTTY 0
#else
#include <termios.h>
#endif
#include <unistd.h>
#include <stdint.h>
#include <vector>
#include <string>
#include <mutex>

using namespace std;

class Serial {
public:
	Serial(string port = "/dev/ttyACM0", int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
	virtual ~Serial();

	bool setParameters(int baudrate = 115200, int stop = 1, int parity = 0, int timeout = 10);
	vector<uint8_t> write_read(vector<uint8_t> v);
	uint16_t genCrc(vector<uint8_t> v);
	bool isOpen() { return fd >= 0; }

protected:
	int write(const vector<uint8_t> &v);
	vector<uint8_t> read();
	mutex write_read_mutex;
private:
	int fd;
};
