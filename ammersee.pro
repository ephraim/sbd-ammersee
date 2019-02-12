TEMPLATE = app

win32:INCLUDEPATH += c:/Qt/boost_1_69_0

QT += qml quick widgets concurrent

CONFIG += c++11
CONFIG -= debug

SOURCES += src/main.cpp src/serial.cpp src/simpleproto.cpp src/misc.cpp src/fileio.cpp
HEADERS += src/serial.h src/simpleproto.h src/qsimpleproto.h src/misc.h src/twn4.sys.h src/fileio.h
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
