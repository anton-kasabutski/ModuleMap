import QtQuick 2.10
import QtLocation 5.9

Rectangle {
    id: root
    property Place place: null
    property real distance: 0
    property var placeIcon: null

    color: "#eeffffff"

    function placeOverview() {
        place = null
        distance = 0
        placeIcon = null
    }

    Text {
        id: title
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        text: root.place ? root.place.name : "TESTABLE PALCE"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
        font.pointSize: 24
        wrapMode: Text.WordWrap
    }

    Text {
        id: textDistance
        anchors.top: title.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: distance + "m"
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        font.pointSize: 22
    }

    Image {
        id: imagePlace
        anchors.top: textDistance.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: parent.width*0.1
        source: root.place && place.imageModel.totalCount > 0 ? place.imageModel[0].url : (placeIcon ? placeIcon : "")
    }
}
