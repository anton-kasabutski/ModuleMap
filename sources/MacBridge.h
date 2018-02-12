#ifndef MACBRIDGE_H
#define MACBRIDGE_H

#include <QObject>

class MacBridge: public QObject
{
    Q_OBJECT
public:
    explicit MacBridge(QObject* parent = 0);

    static MacBridge* instance();

signals:
    void trackpadEmpty();

private:
    static MacBridge* m_instance;
};

#endif // MACBRIDGE_H
