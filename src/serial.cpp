#include <iomanip>
#include <iostream>

#ifdef __GNUC__
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#elif _MSC_VER
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <share.h>
#endif

#include "serial.h"
#include "misc.h"

using namespace std;

#ifndef _WIN32
bool operator ==(const struct termios &a, const struct termios &b)
{
	if(a.c_iflag != b.c_iflag)
		return false;

	if(a.c_oflag != b.c_oflag)
		return false;

	if(a.c_cflag != b.c_cflag)
		return false;

	if(a.c_lflag != b.c_lflag)
		return false;

	for(int i = 0; i < NCCS; i++)
		if(a.c_cc[i] != b.c_cc[i])
			return false;

	return true;
}
#endif

#ifdef __GNUC__
Serial::Serial(string port, int baudrate/* = 115200*/, int stop/* = 1*/, int parity/* = 0*/, int timeout/* = 10*/)
#elif _MSC_VER
Serial::Serial(string port)
#endif
: fd(-1)
{
	if(port.empty())
		return;

#ifdef __GNUC__
    fd = open(port.c_str(), O_RDWR);
#elif _MSC_VER
    errno_t err;
    err = _sopen_s(&fd, port.c_str(), _O_RDWR, _SH_DENYNO, _S_IREAD | _S_IWRITE);
#endif
    if(fd < 0) {
        cerr << "ERROR: could not open " << port << ". Error: " << hex << setw(8) << setfill('0') << errno << endl;
		return;
	}

#ifndef _WIN32
	setParameters(baudrate, stop, parity, timeout);
	write_read_mutex.unlock();
#else
	setParameters();
#endif
}

Serial::~Serial()
{
    if(fd >= 0)
#ifdef __GNUC__
        close(fd);
#elif _MSC_VER
        _close(fd);
#endif
}

#ifndef _WIN32
bool Serial::setParameters(int baudrate/* = 115200*/, int stop/* = 1*/, int parity/* = 0*/, int timeout/* = 10*/)
#else
bool Serial::setParameters()
#endif
{
#ifdef _WIN32
	_setmode(fd, _O_BINARY);
#else
	struct termios ts;
	struct termios tmp;
	speed_t speed = B115200;

	if(fd < 0) {
		cerr << "ERROR: filedescriptor invalid. Could not set parameters" << endl;
		return false;
	}

	switch(baudrate) {
		case 9600: speed = B9600; break;
		case 115200: speed = B115200; break;
		default:
			cerr << "WARNING: unknown baudrate specified: " << dec << baudrate << ". Using default: 115200" << endl;
			break;
	}

	cfmakeraw(&ts);
	cfsetspeed(&ts, speed);

	if(stop == 2) // two stopbits
		ts.c_cflag |= CSTOPB;
	else  // one stopbits
		ts.c_cflag &= ~CSTOPB;

	if(parity == 1) { // with Even Parity
		ts.c_cflag |= PARENB;
		ts.c_cflag &= ~PARODD;
	}
	else if(parity == 2) { // with Odd Parity
		ts.c_cflag |= PARENB;
		ts.c_cflag |= PARODD;
	}
	else { // without any Parity
		ts.c_cflag &= ~PARENB;
		ts.c_cflag &= ~PARODD;
	}

	ts.c_cc[VMIN] = 1;
	ts.c_cc[VTIME] = timeout * 10; // entity: 1/10 seconds

	if(tcsetattr(fd, TCSAFLUSH, &ts) == 0) {
		tcgetattr(fd, &tmp);
		return ts == tmp;
	}
#endif
	return false;
}

vector<uint8_t> Serial::write_read(vector<uint8_t> v)
{
    int i;
	vector<uint8_t> ret;

#ifndef _WIN32
	write_read_mutex.lock();
#endif
	i = write(v);
    if(i != static_cast<int>(v.size()))
		return vector<uint8_t>();
	ret = read();
#ifndef _WIN32
	write_read_mutex.unlock();
#endif
	return ret;
}

int Serial::write(const vector<uint8_t> &v)
{
	uint16_t crc;
	vector<uint8_t> data;
    int size = 2; // + crc(2)

	crc = genCrc(v);
    size += static_cast<int>(v.size());

	data.push_back(size & 0xff);
    data.push_back(static_cast<unsigned char>(size >> 8));
	data.insert(data.end(), v.begin(), v.end());

	data.push_back(crc & 0xff);
	data.push_back(crc >> 8);

	// cout << "WRITE(" << dec << data.size() << "): " << b2h(data) << endl;
#ifdef __GNUC__
	size = ::write(fd, (const void*)data.data(), (size_t)data.size());
#elif _MSC_VER
    size = static_cast<int>(_write(fd, static_cast<const void*>(data.data()), static_cast<unsigned int>(data.size())));
#endif

	if(size >= 4)
		size -= 4; // - crc(2) - size(2)

	return size;
}

vector<uint8_t> Serial::read()
{
	vector<uint8_t> v;
	uint16_t size = 0;
	uint16_t count;
	uint16_t crc;
	vector<uint8_t> tmp;

	tmp.resize(2);
#ifdef __GNUC__
	size = ::read(fd, tmp.data(), (size_t)tmp.size());
#elif _MSC_VER
    size = static_cast<uint16_t>(_read(fd, tmp.data(), static_cast<unsigned int>(tmp.size())));
#endif
	if(size != 2)
		return v;
    size = static_cast<uint16_t>(tmp[0] | tmp[1]<<8);
	//cout << "READ(" << dec << size << "): ";

	tmp.clear();
	tmp.resize(size);
	while(size != v.size()) {
#ifdef __GNUC__
        count = ::read(fd, tmp.data(), (size_t)tmp.size());
#elif _MSC_VER
        count = static_cast<uint16_t>(_read(fd, tmp.data(), static_cast<unsigned int>(tmp.size())));
#endif
		v.insert(v.end(), tmp.begin(), tmp.begin() + count);
	}
	// cout << b2h(v) << endl;
    crc = static_cast<uint16_t>(v[v.size() - 2] | v[v.size() - 1]<<8);
	v.erase(v.end() - 2, v.end());

	if(crc != genCrc(v))
		return vector<uint8_t>();

	return v;
}

uint16_t Serial::genCrc(vector<uint8_t> v)
{
	uint16_t ret = 0xFFFF;
	uint16_t b;

	for(unsigned int i = 0; i < v.size(); i++) {
		b = v[i];
        b ^= static_cast<uint8_t>(ret);
        b ^= static_cast<uint8_t>(b << 4);
        ret = static_cast<uint16_t>(((b << 8) | (ret >> 8)) ^ (b >> 4) ^ (b << 3));
	}

	return ret;
}
