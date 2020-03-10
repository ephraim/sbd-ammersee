#include <QApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QtQml>
#include "twn4.sys.h"
#include "qsimpleproto.h"
#include "fileio.h"
#include <iostream>

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	QCoreApplication::setApplicationName("ammersee");
    QCoreApplication::setApplicationVersion("1.0");

	qmlRegisterType<FileIO>("MyCustomClasses", 1, 0, "FileIOQML");

    QString port = "";
	QCommandLineParser parser;
	QCommandLineOption portOption(QStringList() << "p" << "port", "RFID-Reader serial port", "port");

	parser.addHelpOption();
	parser.addVersionOption();
	parser.setApplicationDescription("SB Delphin 03 Augsburg - Ammerseeschwimmen");
	parser.addOption(portOption);
	parser.process(app);

	if (parser.isSet(portOption))
		port = parser.value(portOption);
	else {
		std::cout << "No serial port specified! exiting ..." << std::endl;
		return 1;
	}

	QSimpleProtocolClient spc(port);
	QQmlApplicationEngine engine;
	QQmlContext *cntxt = engine.rootContext();
	app.setProperty("engine", QVariant::fromValue(&engine));

	spc.setTagTypes(TAGMASK(LFTAG_EM4102), TAGMASK(HFTAG_MIFARE));
	cntxt->setContextProperty("spc", &spc);
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	return app.exec();
}
