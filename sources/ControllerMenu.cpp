#include "ControllerMenu.h"

ControllerMenu::ControllerMenu(QObject *parent) : QObject(parent), m_statusPOI(OFF) {

}


int ControllerMenu::elementsCount() const {
    return 3;
}

ControllerMenu::StatusPOI ControllerMenu::statusPOI() const {
    return m_statusPOI;
}

void ControllerMenu::setStatusPOI(int value) {
    if (m_statusPOI != StatusPOI(value)) {
        StatusPOI previousStatus = m_statusPOI;
        m_statusPOI = StatusPOI(value);
        emit statusPOIChanged(previousStatus);
    }
}

ControllerMenu::MenuElement ControllerMenu::getElementType(int index) const {
    return MenuElement(index);
}

QString ControllerMenu::getImage(int index) const {
    switch (index) {
    case 0:
        return "qrc:/assets/map_menu_location.png";
    case 1:
        return "qrc:/assets/map_menu_navigation.png";
    case 2:
        if (m_statusPOI == OFF)
            return "qrc:/assets/map_menu_poi_off.png";
        else if (m_statusPOI == LOADING)
            return "qrc:/assets/map_menu_poi_loading.png";
        else if (m_statusPOI == READY)
            return "qrc:/assets/map_menu_poi_ready.png";
        break;
    }
    return "";
}
