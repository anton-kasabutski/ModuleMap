import QtQuick 2.10
import QtLocation 5.9
import QtPositioning 5.9

import Mercedes.ModuleMap 1.0

import "../Items"

Item {
    id: root
    property alias center: map.center
    property alias plugin: map.plugin
    signal menuRequested()

    function updatePosition() {
        map.isLocked = false
        mapPosition.active = true
    }

    function updateDestination(destination) {
        mapItemView.model.clear()
        mapItemView.model.append({"destination" : destination})
        map.center = destination.coordinate
    }

    Map {
        id: map
        property bool isLocked: false
        property variant userPosition: null
        anchors.fill: parent
        plugin: Plugin {
            id: mapPlugin
            name: "here"
            PluginParameter { name: "here.app_id"; value: "EbUH2sZBXnxtnOMofxVh" }
            PluginParameter { name: "here.token"; value: "_KlbaNhb7XBpnW7yjptJtw" }
        }

        center: QtPositioning.coordinate(59.91, 10.75) // Oslo
        zoomLevel: 14

        MapQuickItem {
            coordinate: map.userPosition !== null ? map.userPosition : QtPositioning.coordinate()
            anchorPoint.x: sourceItem.width * 0.5
            anchorPoint.y: sourceItem.height
            sourceItem: Image {
                source: "qrc:/assets/map_menu_location.png"
                width: 25
                height: width
            }
        }

        MapItemView {
            id: mapItemView
            model: ListModel {}
            delegate: MapQuickItem {
                coordinate: destination.coordinate
                anchorPoint.x: sourceItem.width * 0.5
                anchorPoint.y: sourceItem.height
                sourceItem: Image {
                    source: "qrc:/assets/map_destination.png"
                    width: 50
                    height: width
                }
            }
        }

        MapItemView {
            model: poiModel
            delegate: MapQuickItem {
                coordinate: model.type === PlaceSearchModel.PlaceResult ? place.location.coordinate : QtPositioning.coordinate()
                visible: place.icon.url() !== ""
                anchorPoint.x: sourceItem.width * 0.28
                anchorPoint.y: sourceItem.height

                sourceItem: Image {
                    source: place.icon.url() === "" ? "qrc:/assets/map_marker.png" : place.icon.url(Qt.size(40,40))
                }
            }
        }

        Connections {
            target: ControllerMenu
            onStatusPOIChanged: {
                if (ControllerMenu.statusPOI === ControllerMenu.LOADING) {
                    poiModel.reset()
                    poiModel.update()
                } else if (ControllerMenu.statusPOI === ControllerMenu.OFF) {
                    if (previousStatus === ControllerMenu.LOADING)
                        poiModel.cancel()
                    else
                        poiModel.reset()
                    placeOverview.reset()
                }
            }
        }

        PlaceSearchModel {
            id: poiModel
            searchArea: QtPositioning.circle(map.center)
            plugin: map.plugin

            onStatusChanged: {
                if (status === PlaceSearchModel.Ready) {
                    ControllerMenu.statusPOI = ControllerMenu.READY
                    if (count > 0) {
                        placeOverview.place = data(0, "place")
                        placeOverview.distance = data(0, "distance")
                        placeOverview.placeIcon = data(0,"icon").url()
                    }
                } else if (status === PlaceSearchModel.Error)
                    ControllerMenu.statusPOI = ControllerMenu.OFF
            }
        }

        PositionSource {
            id: mapPosition
            updateInterval: 5000
            active: true
            onPositionChanged: {
                if ((position.latitudeValid && position.longitudeValid)) {
                    mapAnimation.stop()
                    mapAnimation.dx = 0
                    mapAnimation.dy = 0
                    map.center = position.coordinate
                    map.userPosition = position.coordinate
                    active = false
                }
            }
        }

        CoordinateAnimation {
            id: mapAnimation
            property double dx: 0
            property double dy: 0
            property double moveThreshold: 0.35
            //property double speed: 1.001 - Math.sqrt(1 - (map.zoomLevel - map.minimumZoomLevel)/(map.maximumZoomLevel - map.minimumZoomLevel), 5)
            //property double speed: 1.001 + Math.sin(Math.PI + Math.PI/2*((map.zoomLevel - map.minimumZoomLevel)/(map.maximumZoomLevel - map.minimumZoomLevel)))
            property double speed: 0.301 - 0.3*(map.zoomLevel - map.minimumZoomLevel)/(map.maximumZoomLevel - map.minimumZoomLevel)
            duration: 2000
            target: map
            property: "center"
            onDxChanged: {
                if (running)
                    stop()
                else onStopped()
            }
            onDyChanged: {
                if (running)
                    stop()
                else onStopped()
            }
            function prepareAnimation() {
                from = map.center
                var deltaX = Math.max((Math.abs(dx) - moveThreshold), 0) / (1 - moveThreshold) * (dx < 0 ? -speed : speed);
                var deltaY = Math.max((Math.abs(dy) - moveThreshold), 0) / (1 - moveThreshold) * (dy < 0 ? speed : -speed);
                to = QtPositioning.coordinate(map.center.latitude + deltaY, map.center.longitude + deltaX)
            }
            onStopped: {
                if (map.isLocked || (Math.abs(dy) < moveThreshold && Math.abs(dx) < moveThreshold))
                    return;
                prepareAnimation()
                start()
            }
        }
    }


    Image {
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width*0.05
        height: parent.height*0.04
        source: "qrc:/assets/map_status_background.png"
        mirror: true

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.width*0.05
            width: parent.width*0.5
            height: parent.height*0.7
            source: map.isLocked ? "qrc:/assets/map_status_lock.png" : "qrc:/assets/map_status_explore.png"
        }
    }

    Image {
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.width*0.05
        height: parent.height*0.04
        source: "qrc:/assets/map_status_background.png"
    }

    ItemTouchArea {
        anchors.fill: parent
        property double moveThreshold: 0.8
        hoverEnabled: true

        onTrackpadEmpty: {
            if (containsMouse)
                Utils.centerCursor()
        }

        onPositionChanged: {
            var xPos = (mouse.x - width/2)/(width/2)
            var yPos = (mouse.y - height/2)/(height/2)
            mapAnimation.dx = xPos
            mapAnimation.dy = yPos
        }

        onClicked: {
            if (timerDoubleClick.running) {
                timerDoubleClick.stop()
                map.isLocked = true
                root.menuRequested()
            } else {
                timerDoubleClick.start()
                if (placeOverview.place) {
                    for (var i=0; i<poiModel.count; i++)
                        if (placeOverview.place === poiModel.data(i, "place")) {
                            var index = 0
                            if (i<poiModel.count - 1)
                                index = i+1
                            placeOverview.place = poiModel.data(index, "place")
                            placeOverview.distance = poiModel.data(index, "distance")
                            placeOverview.placeIcon = poiModel.data(index,"icon").url()
                            break;
                        }
                } else {
                    if (map.isLocked)
                        Utils.centerCursor();
                    map.isLocked = !map.isLocked
                    mapAnimation.stop()
                }
            }
        }

        //onDoubleClicked is unusable here - cursor is shifting/moving for simulation
        Timer {
            id: timerDoubleClick
            interval: 250
        }
    }

    ItemPlaceOverview {
        id: placeOverview
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height*0.05
        width: parent.width*0.3
        height: width
        state: place ? "SHOWN" : "HIDDEN"
        states: [State {
                name: "SHOWN"
                PropertyChanges { target: placeOverview; anchors.leftMargin: 0 }
            }, State {
                name: "HIDDEN"
                PropertyChanges { target: placeOverview; anchors.leftMargin: -placeOverview.width}
            }]
        transitions: Transition {
            NumberAnimation  {
                duration: 250
                easing.type: Easing.InOutQuad
                properties: "anchors.leftMargin"
            }
        }
    }

}
