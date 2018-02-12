import QtQuick 2.10
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtPositioning 5.9

import Mercedes.ModuleMap 1.0

import "Views"

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("ModuleMap")

    StackView {
        id: stackView
        initialItem: componentMap
        anchors.fill: parent

        Component {
            id: componentMap
            Item {
                ViewMap {
                    id: map
                    anchors.fill: parent
                    onMenuRequested: menu.show()
                }

                ViewMenu {
                    id: menu
                    anchors.fill: parent
                    onPositionUpdateRequested: map.updatePosition()
                    onNavigationRequested: {
                        Utils.centerCursor()
                        Utils.showCursor()
                        stackView.push(componentNavigation, {suggestionPlugin:map.plugin, searchArea: QtPositioning.circle(map.center)})
                        stackView.currentItem.onDestUpdateRequested.connect(map.updateDestination)
                    }
                }
            }
        }

        Component {
            id: componentNavigation
            ViewNavigation {
                onMenuRequested: {
                    Utils.hideCursor()
                    Utils.centerCursor()
                    stackView.pop()
                }
                onDestUpdateRequested: {
                    Utils.hideCursor()
                    Utils.centerCursor()
                    stackView.pop()
                }
            }
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
        font.bold: true
        font.pixelSize: 18
        color: "white"

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered:  parent.text = Qt.formatDateTime(new Date(), "hh:mm")
            Component.onCompleted: onTriggered()
        }
    }
}
