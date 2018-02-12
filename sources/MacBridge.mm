#include "MacBridge.h"
#include "MacTrackpadObserver.h"

#include <QGuiApplication>
#include <QWindow>
#include <QDebug>
#include <QTimer>

#include <Cocoa/Cocoa.h>


MacBridge* MacBridge::m_instance = Q_NULLPTR;
MacBridge::MacBridge(QObject* parent): QObject(parent) {
    m_instance = this;
    NSView *nativeView = reinterpret_cast<NSView *>(QGuiApplication::allWindows().first()->winId());
    [nativeView enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
    MacTrackpadObserver *observer = [[MacTrackpadObserver alloc] initWithFrame:[nativeView frame]];
    [nativeView addSubview:observer];
    [observer setBridge:^() {
        emit MacBridge::instance()->trackpadEmpty();
    }];
}

MacBridge* MacBridge::instance() {
    return m_instance;
}
