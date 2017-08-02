#include <QObject>
#include <QFileDialog>
#include <QDebug>
#include <fstream>

class FileIO : public QObject
{
    Q_OBJECT
public:
    FileIO() {};
    ~FileIO() {};

public slots:
    void openFileDlg();    
};