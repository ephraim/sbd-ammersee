TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11 debug

SOURCES += src/main.cpp

RESOURCES += qml/qml.qrc

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
