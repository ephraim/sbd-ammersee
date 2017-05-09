TEMPLATE = app

QT += qml quick widgets concurrent

CONFIG += c++11

SOURCES += src/main.cpp src/serial.cpp src/simpleproto.cpp src/misc.cpp
HEADERS += src/serial.h src/simpleproto.h src/qsimpleproto.h src/misc.h src/twn4.sys.h

RESOURCES += qml/qml.qrc
DEFINES += MAKEFIRMWARE

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

release: DESTDIR = build/release
debug:   DESTDIR = build/debug

execute.commands = $$DESTDIR/ammersee
execute.depends = "$(TARGET)"

QMAKE_EXTRA_TARGETS += execute


OBJECTS_DIR = $$DESTDIR/obj
MOC_DIR = $$DESTDIR/moc
RCC_DIR = $$DESTDIR/rcc
UI_DIR = $$DESTDIR/ui
