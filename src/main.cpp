#include <QApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "twn4.sys.h"
#include "qsimpleproto.h"

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

	QSimpleProtocolClient spc;
	QQmlApplicationEngine engine;
	QQmlContext *cntxt = engine.rootContext();

	spc.setTagTypes(TAGMASK(LFTAG_EM4102), TAGMASK(HFTAG_MIFARE));
	cntxt->setContextProperty("spc", &spc);
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

	return app.exec();
}
