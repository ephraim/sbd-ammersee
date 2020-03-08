#include "windows_serial.h"
#include <iostream>
#include <iomanip>

using namespace std;

#define DEBUG std::cout << __FILE__ << ":" << __LINE__ << std::endl

void outputError()
{
    TCHAR lastError[1024] = {};
    FormatMessage(
        FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        GetLastError(),
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        lastError,
        1024,
        NULL);
    cout << "Last error: " << lastError << endl;
}

WindowsSerial::WindowsSerial(std::string port/* = "COM1"*/, int baudrate/* = CBR_115200*/, int stop/* = ONESTOPBIT*/, int parity/* = NOPARITY*/, int timeout/* = 20*/)
: Serial(), hSerial(INVALID_HANDLE_VALUE)
{
    cout << "Trying to open " << port << "..." << endl;
    hSerial = CreateFile((LPTSTR)port.c_str(), GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if(isOpen()) {
        setParameters(baudrate, stop, parity, timeout);
        return;
    }

    cout << "CreateFile failed: 0x" << hex << setfill('0') << GetLastError() << endl;
}

WindowsSerial::~WindowsSerial()
{
    CloseHandle(hSerial);
}

bool WindowsSerial::setParameters(int baudrate/* = CBR_115200*/, int stop/* = ONESTOPBIT*/, int parity/* = NOPARITY*/, int timeout/* = 20*/) 
{
    DCB dcbSerialParams;
    COMMTIMEOUTS timeouts;

    dcbSerialParams.DCBlength=sizeof(dcbSerialParams);

    if (!GetCommState(hSerial, &dcbSerialParams)) {
        cout << "ERROR: GetCommState" << endl;
        return false;
    }

    dcbSerialParams.BaudRate=baudrate;
    dcbSerialParams.ByteSize=8;
    dcbSerialParams.StopBits=stop;
    dcbSerialParams.Parity=parity;
    if(!SetCommState(hSerial, &dcbSerialParams)){
        cout << "ERROR: SetCommState" << endl;
        return false;
    }

    timeouts.ReadIntervalTimeout=timeout;
    timeouts.ReadTotalTimeoutConstant=timeout;
    timeouts.ReadTotalTimeoutMultiplier=timeout;
    timeouts.WriteTotalTimeoutConstant=timeout;
    timeouts.WriteTotalTimeoutMultiplier=timeout;
    if(!SetCommTimeouts(hSerial, &timeouts)){
        cout << "ERROR: SetCommTimeouts" << endl;
        return false;
    }
    return true;
}

bool WindowsSerial::isOpen()
{
    return !(hSerial == INVALID_HANDLE_VALUE);
}

int WindowsSerial::_write(const std::vector<uint8_t> &data) 
{
    DWORD dwBytesWritten = 0;

    if(!WriteFile(hSerial, data.data(), data.size(), &dwBytesWritten, NULL))
        return -1;
    
    return dwBytesWritten;
}

std::vector<uint8_t> WindowsSerial::_read() 
{
    vector<uint8_t> data;
    DWORD dwBytesRead = 0;

    data.resize(1024);
    if(!ReadFile(hSerial, data.data(), data.size(), &dwBytesRead, NULL)) {
        DEBUG;
        return std::vector<uint8_t>();
    }

    data.resize(dwBytesRead);
    return data;
}
