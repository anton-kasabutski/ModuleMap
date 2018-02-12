import QtQuick 2.10

import Mercedes.ModuleMap 1.0

Rectangle {
    id: root
    property int selectedItemIndex: 0
    property int poiStatus: 0
    signal positionUpdateRequested()
    signal navigationRequested()
    anchors.fill: parent
    state: "HIDDEN"
    states: [State {
            name: "SHOWN"
            PropertyChanges { target: root; opacity: 1 }
            PropertyChanges { target: mouseOverlay; visible: true }
        }, State {
            name: "HIDDEN"
            PropertyChanges { target: root; opacity: 0 }
            PropertyChanges { target: mouseOverlay; visible: false }
        }]
    transitions: Transition {
        NumberAnimation  {
            duration: 650
            easing.type: Easing.InOutQuad
            properties: "opacity"
        }
    }
    opacity: 0
    color: "#66000000"

    function show() {
        state = "SHOWN"
        selectedItemIndex = 0
    }

    function hide() {
        state = "HIDDEN"
    }

    MouseArea {
        id: mouseOverlay
        property int wheelPosition: 0
        property int wheelThreshold: 50
        anchors.fill: parent
        onClicked: timerDoubleClick.start()

        onDoubleClicked: {
            timerDoubleClick.stop()
            hide();
        }

        Timer {
            id: timerDoubleClick
            interval: 150
            onTriggered: {
                if (ControllerMenu.getElementType(root.selectedItemIndex) === ControllerMenu.USER_POSITION) {
                    root.positionUpdateRequested()
                } else if (ControllerMenu.getElementType(root.selectedItemIndex) === ControllerMenu.DESTINATION) {
                    root.navigationRequested()
                } else if (ControllerMenu.getElementType(root.selectedItemIndex) === ControllerMenu.POI) {
                    if (ControllerMenu.statusPOI === ControllerMenu.OFF)
                        ControllerMenu.statusPOI = ControllerMenu.LOADING
                    else
                        ControllerMenu.statusPOI = ControllerMenu.OFF
                }
                hide();
            }
        }

        onWheel: {
            if (timerDoubleClick.running)
                return
            wheelPosition += wheel.pixelDelta.x
            if (wheelPosition > wheelThreshold) {
                wheelPosition = 0;
                if (root.selectedItemIndex < ControllerMenu.elementsCount - 1)
                    root.selectedItemIndex++;
            } else if (wheelPosition < -wheelThreshold) {
                wheelPosition = 0;
                if (root.selectedItemIndex > 0)
                    root.selectedItemIndex--;
            }
        }
        Timer {
            running: true
            repeat: true
            interval: 250
            onTriggered: mouseOverlay.wheelPosition /= 1.5
        }
    }

    Component {
        id: componentMenuElement
        Image {
            id: menuElementBackground
            property alias sourceOverlay: menuElementOverlay.source
            property int itemPosition: 0
            height: width
            anchors.horizontalCenter: root.horizontalCenter
            anchors.verticalCenter: root.verticalCenter
            anchors.verticalCenterOffset: root.height
            state: root.state
            states: [State {
                    name: "SHOWN"
                    PropertyChanges { target: menuElementBackground; anchors.verticalCenterOffset: 0 }
                }, State {
                    name: "HIDDEN"
                    PropertyChanges { target: menuElementBackground; anchors.verticalCenterOffset: root.height }
                }]
            transitions: Transition {
                SequentialAnimation {
                    PauseAnimation {
                        duration: itemPosition*50
                    }
                    NumberAnimation  {
                        duration: 600
                        easing.type: Easing.InOutCirc
                        properties: "anchors.verticalCenterOffset"
                    }
                }
            }
            source: root.selectedItemIndex === itemPosition ? "qrc:/assets/map_menu_elementbg_active.png" : "qrc:/assets/map_menu_elementbg.png"

            Image {
                id: menuElementOverlay
                anchors.fill: parent
                anchors.margins: parent.width*0.2
                function updateOverlayImage() {
                    if (ControllerMenu.getElementType(itemPosition) === ControllerMenu.POI)
                        source = ControllerMenu.getImage(ControllerMenu.POI)
                }

                Component.onCompleted: {
                    if (ControllerMenu.getElementType(itemPosition) === ControllerMenu.POI)
                        ControllerMenu.onStatusPOIChanged.connect(updateOverlayImage)
                }
            }
        }
    }

    //We can't use Component.onCompleted because of StackView initialization [parent.width would be equal 0]
    Timer {
        running: true
        interval: 0
        onTriggered: {
            for (var i=0; i<ControllerMenu.elementsCount; i++)
                componentMenuElement.createObject(root, {
                                                     "width" : parent.width/4,
                                                     "anchors.horizontalCenterOffset" : parent.width*(i-1)/4,
                                                     "sourceOverlay" : ControllerMenu.getImage(ControllerMenu.getElementType(i)),
                                                     "itemPosition" : i
                                                 })
        }
    }
}
