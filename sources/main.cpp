#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "MacBridge.h"
#include "Utils.h"
#include "ControllerMenu.h"

#include <QCursor>
#include <QTimer>

template <class T>
static QObject* singletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new T();
}

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterSingletonType<Utils>("Mercedes.ModuleMap", 1, 0, "Utils", singletonProvider<Utils>);
    qmlRegisterSingletonType<ControllerMenu>("Mercedes.ModuleMap", 1, 0, "ControllerMenu", singletonProvider<ControllerMenu>);
    qmlRegisterSingletonType<MacBridge>("Mercedes.ModuleMap", 1, 0, "MacBridge", singletonProvider<MacBridge>);
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    QTimer::singleShot(100, [=] { Utils::hideCursor(); });

    return app.exec();
}
