#include <QApplication>
#include <QWidget>
#include <QQmlApplicationEngine>
#include "fileio.h"

void FileIO::openFileDlg() {
    QQmlApplicationEngine *engine = QCoreApplication::instance()->property("engine").value<QQmlApplicationEngine*>();
    QString fileName = QFileDialog::getSaveFileName((QWidget*)engine, tr("Save File"), "", tr("CSV-Files (*.csv)"));
    qDebug() << fileName;
}