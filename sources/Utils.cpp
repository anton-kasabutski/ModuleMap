#include "Utils.h"

#include <QGuiApplication>
#include <QWindow>

Utils::Utils(QObject* parent): QObject(parent) {}

void Utils::centerCursor() {
    QWindow* currentWindow = QGuiApplication::allWindows().first();
    QCursor::setPos(currentWindow->position().x() + currentWindow->size().width()/2, currentWindow->position().y() + currentWindow->size().height()/2);
}

void Utils::showCursor() {
    qApp->setOverrideCursor(QCursor(Qt::ArrowCursor));
    qApp->changeOverrideCursor(QCursor(Qt::ArrowCursor));
}

void Utils::hideCursor() {
    qApp->setOverrideCursor(QCursor(Qt::BlankCursor));
    qApp->changeOverrideCursor(QCursor(Qt::BlankCursor));
}
