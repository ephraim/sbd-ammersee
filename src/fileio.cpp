#include <QApplication>
#include <QWidget>
#include <QQmlApplicationEngine>
#include "fileio.h"

void FileIO::openFileDlg() {
    QString fileName = QFileDialog::getSaveFileName(NULL, tr("Save File"), "", tr("CSV-Files (*.csv)"));
    setProperty("fileName", fileName);
}

void FileIO::openFile(QString fileName)
{
    if(!fileName.isEmpty()) {
        f.setFileName(fileName);
        f.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text);
    }
}

void FileIO::writeLine(QString line)
{
    if(f.isOpen())
        f.write((line + "\n").toUtf8());
}

void FileIO::closeFile()
{
    if(f.isOpen())
        f.close();
}
