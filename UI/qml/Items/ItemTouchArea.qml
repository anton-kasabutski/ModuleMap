import QtQuick 2.10

import Mercedes.ModuleMap 1.0


MouseArea {
    id: root
    signal trackpadEmpty()

    Component.onCompleted: MacBridge.onTrackpadEmpty.connect(root.trackpadEmpty)
}
