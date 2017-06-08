#!/bin/bash
export MXE_HOME=${HOME}/Projekte/mxe/usr/x86_64-w64-mingw32.shared
export DEST_DIR=../image

mkdir -p ${DEST_DIR}/qml/QtQuick/LocalStorage
mkdir -p ${DEST_DIR}/qml/QtQuick.2
mkdir -p ${DEST_DIR}/plugins/sqldrivers
mkdir -p ${DEST_DIR}/plugins/platforms

install ${MXE_HOME}/qt5/bin/Qt5Widgets.dll		${DEST_DIR}/
install ${MXE_HOME}/qt5/bin/Qt5Quick.dll		${DEST_DIR}/
install ${MXE_HOME}/qt5/bin/Qt5Qml.dll			${DEST_DIR}/
install ${MXE_HOME}/qt5/bin/Qt5Sql.dll			${DEST_DIR}/
install ${MXE_HOME}/qt5/bin/Qt5Core.dll			${DEST_DIR}/
install ${MXE_HOME}/qt5/bin/Qt5Svg.dll			${DEST_DIR}/
install ${MXE_HOME}/qt5/bin/Qt5Gui.dll			${DEST_DIR}/
install ${MXE_HOME}/qt5/bin/Qt5Network.dll		${DEST_DIR}/
install ${MXE_HOME}/qt5/qml/QtQuick/LocalStorage/qmllocalstorageplugin.dll	${DEST_DIR}/qml/QtQuick/LocalStorage/
install ${MXE_HOME}/qt5/qml/QtQuick.2/qtquick2plugin.dll	${DEST_DIR}/qml/QtQuick.2/
install ${MXE_HOME}/qt5/plugins/sqldrivers/qsqlite.dll		${DEST_DIR}/plugins/sqldrivers/
install ${MXE_HOME}/qt5/plugins/platforms/qwindows.dll		${DEST_DIR}/plugins/platforms/

install ${MXE_HOME}/bin/libgcc_s_seh-1.dll	${DEST_DIR}/
install ${MXE_HOME}/bin/libstdc++-6.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libpcre2-16-0.dll	${DEST_DIR}/
install ${MXE_HOME}/bin/zlib1.dll			${DEST_DIR}/
install ${MXE_HOME}/bin/ssleay32.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libeay32.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libharfbuzz-0.dll	${DEST_DIR}/
install ${MXE_HOME}/bin/libpng16-16.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libfreetype-6.dll	${DEST_DIR}/
install ${MXE_HOME}/bin/libglib-2.0-0.dll	${DEST_DIR}/
install ${MXE_HOME}/bin/libbz2.dll			${DEST_DIR}/
install ${MXE_HOME}/bin/libintl-8.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libpcre-1.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libiconv-2.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libsqlite3-0.dll	${DEST_DIR}/
install ${MXE_HOME}/bin/libjasper-1.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libjpeg-9.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libmng-2.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libtiff-5.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libwebp-5.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/libwebpdemux-1.dll	${DEST_DIR}/
install ${MXE_HOME}/bin/liblcms2-2.dll		${DEST_DIR}/
install ${MXE_HOME}/bin/liblzma-5.dll		${DEST_DIR}/
