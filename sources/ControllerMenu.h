#ifndef CONTROLLERMENU_H
#define CONTROLLERMENU_H

#include <QObject>

class ControllerMenu : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int elementsCount READ elementsCount CONSTANT)
    Q_PROPERTY(StatusPOI statusPOI READ statusPOI WRITE setStatusPOI NOTIFY statusPOIChanged)
public:
    explicit ControllerMenu(QObject *parent = nullptr);

    enum StatusPOI {
        OFF,
        LOADING,
        READY
    };
    Q_ENUMS(StatusPOI)

    enum MenuElement {
        USER_POSITION,
        DESTINATION,
        POI
    };
    Q_ENUMS(MenuElement)

    int elementsCount() const;

    StatusPOI statusPOI() const;
    void setStatusPOI(int value);

    Q_INVOKABLE QString getImage(int index) const;
    Q_INVOKABLE MenuElement getElementType(int index) const;

signals:
    void statusPOIChanged(StatusPOI previousStatus);

private:
    StatusPOI m_statusPOI;
};

#endif // CONTROLLERMENU_H
