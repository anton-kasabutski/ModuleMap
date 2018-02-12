#ifndef UTILS_H
#define UTILS_H

#include <QObject>

class Utils: public QObject
{
    Q_OBJECT
public:
    explicit Utils(QObject* parent = 0);

    Q_INVOKABLE void centerCursor();
    Q_INVOKABLE void showCursor();
    Q_INVOKABLE static void hideCursor();
};

#endif // UTILS_H
