QT += quick positioning
CONFIG += c++11 disable-desktop
QTPLUGIN += qtvirtualkeyboardplugin

DEFINES += QT_DEPRECATED_WARNINGS
RESOURCES += UI/qml.qrc

LIBS += -framework Cocoa

SOURCES += sources/main.cpp \
    sources/Utils.cpp \
    sources/ControllerMenu.cpp

OBJECTIVE_SOURCES += sources/MacBridge.mm  \
    sources/MacTrackpadObserver.m

HEADERS += \
    sources/MacBridge.h \
    sources/Utils.h \
    sources/ControllerMenu.h \
    sources/MacTrackpadObserver.h

OTHER_FILES += $$PWD/UI/qml/main.qml \
               $$PWD/UI/qml/Views/ViewMap.qml \
               $$PWD/UI/qml/Views/ViewMenu.qml \
               $$PWD/UI/qml/Views/ViewNavigation.qml \
               $$PWD/UI/qml/Items/ItemTouchArea.qml \
               $$PWD/UI/qml/Items/ItemPlaceOverview.qml
