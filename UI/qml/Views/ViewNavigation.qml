import QtQuick 2.10
import QtQuick.VirtualKeyboard 2.1
import QtGraphicalEffects 1.0
import QtLocation 5.9
import QtPositioning 5.9

Rectangle {
    id: root
    property alias searchArea: suggestionModel.searchArea
    property alias suggestionPlugin: suggestionModel.plugin
    signal menuRequested()
    signal destUpdateRequested(var location)

    color: "black"

    function navigateToAddress(text) {
        keyboard.state = "HIDDEN"
        addressInput.enabled = false
        listViewSuggestions.model = null
        imageMarsLogoBehaviorRotation.enabled = true
        imageMersLogo.rotation = 360

        geocodeModel.isResultFailed = false
        geocodeModel.query = text
        geocodeModel.update()
    }


    GeocodeModel {
        id: geocodeModel
        property bool isResultFailed: false
        plugin: suggestionModel.plugin
        limit: 1
        onStatusChanged: {
            if (status == GeocodeModel.Ready && count > 0) {
                root.destUpdateRequested(get(0))
            } else if (status == GeocodeModel.Error || (status == GeocodeModel.Ready && count === 0)) {
                isResultFailed = true
            }
        }
    }

    Image {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: keyboard.top
        source: "qrc:/assets/navigation_background.jpg"
    }

    Text {
        id: addressLabel
        anchors.left: parent.left
        anchors.leftMargin: contentHeight*2
        anchors.verticalCenter: addressInputBackground.verticalCenter
        text: qsTr("Address:")
        font.bold: true
        font.pixelSize: 22
        color: "white"
    }

    Rectangle {
        id: addressInputBackground
        anchors.left: addressLabel.right
        anchors.leftMargin: addressLabel.anchors.leftMargin
        anchors.top: parent.top
        anchors.topMargin: addressLabel.contentHeight
        width: parent.width*0.7
        height: addressLabel.height*1.5
        radius: 10
        color: "#efffffff"
        border.width: 1
        border.color: "#bb888888"
        clip: true

        TextInput {
            id: addressInput
            anchors.fill: parent
            anchors.leftMargin: 4
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 22
            font.bold: true
            focus: true
            onTextChanged: {
                suggestionModel.cancel()
                suggestionModel.searchTerm = text
                suggestionModel.update()
            }
            Keys.onReturnPressed: {
                if (text)
                    root.navigateToAddress(text)
            }
            Component.onCompleted: forceActiveFocus()
        }
    }

    Item {
        anchors.top: addressInputBackground.bottom
        anchors.bottom: keyboard.top
        anchors.horizontalCenter: parent.horizontalCenter
        Image {
            id: imageMersLogo
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 20
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: height
            source: "qrc:/assets/navigation_mers.png"

            Behavior on rotation {
                id: imageMarsLogoBehaviorRotation
                NumberAnimation {
                    duration: 4000
                    onRunningChanged: {
                        if (!running) {
                            if (geocodeModel.isResultFailed) {
                                keyboard.state = "SHOWN"
                                addressInput.enabled = true
                                imageMarsLogoBehaviorRotation.enabled = false
                                imageMersLogo.rotation = 0
                                imageMersAnimationFailed.start()
                            } else imageMersLogo.rotation += 360
                        }
                    }
                }
            }
        }

        Colorize {
            id: imageMersColorizer
            anchors.fill: imageMersLogo
            opacity: 0
            source: imageMersLogo
            saturation: 0.4
        }

        SequentialAnimation {
            id: imageMersAnimationFailed
            loops: 3
            OpacityAnimator {
                target: imageMersColorizer
                to: 1
                duration: 175
            }
            OpacityAnimator {
                target: imageMersColorizer
                to: 0
                duration: 25
            }
        }
    }

    Item {
        anchors.top: addressInputBackground.bottom
        anchors.bottom: keyboard.top
        anchors.left: parent.left

        Image {
            id: imageBackBg
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: width*0.1
            height: parent.height*0.3
            width: root.width*0.06
            antialiasing: true
            smooth: true
            source: "qrc:/assets/navigation_back.png"

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    if (containsMouse)
                        root.menuRequested()
                }
            }
        }

        Colorize {
            id: imageBackColorizer
            anchors.fill: imageBackBg
            source: imageBackBg
            hue: 0.35
            saturation: 0.3
            lightness: -0.3
        }

        PauseAnimation {
            id: imageBackPauseAnimation
            duration: 2000
            onStopped: imageBackAnimation.start()
        }
        PropertyAnimation {
            id: imageBackAnimation
            running: true
            duration: 2000
            target: imageBackColorizer
            property: "saturation"
            from: imageBackColorizer.saturation
            to: 0
            onStopped: {
                from = imageBackColorizer.saturation
                if (to === 0) {
                    to = 0.3
                    imageBackPauseAnimation.start()
                } else {
                    to = 0
                    start()
                }
            }
        }

    }

    ListView {
        id: listViewSuggestions
        anchors.left: addressInputBackground.left
        anchors.right: addressInputBackground.right
        anchors.top: addressInputBackground.bottom
        anchors.bottom: keyboard.top
        function setAddressText(text) {
            addressInput.text = text
            suggestionModel.cancel()
            root.navigateToAddress(text)
        }

        delegate: Rectangle {
            width: listViewSuggestions.width
            height: listViewSuggestions.height/5
            radius: 10
            color: suggestionMouseArea.containsMouse ? "#ef71d5e4" : "#efffffff"
            border.width: 1
            border.color: "#bb888888"
            Text {
                id: label
                anchors.fill: parent
                anchors.leftMargin: 4
                color: "black"
                verticalAlignment: Text.AlignVCenter
                text: modelData
                font.pixelSize: 22
                font.bold: true
            }
            MouseArea {
                id: suggestionMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    listViewSuggestions.setAddressText(modelData)
                }
            }
        }
    }

    PlaceSearchSuggestionModel {
        id: suggestionModel
        limit: 3

        onStatusChanged: {
            listViewSuggestions.model = null
            if (status === PlaceSearchSuggestionModel.Ready && suggestions.length > 0)
                listViewSuggestions.model = suggestions.slice(0,3)
        }
    }

    InputPanel {
        id: keyboard
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        state: "SHOWN"
        states: [State {
                name: "SHOWN"
                PropertyChanges { target: keyboard; enabled: true }
                PropertyChanges { target: keyboard; opacity: 1 }
            }, State {
                name: "HIDDEN"
                PropertyChanges { target: keyboard; enabled: false }
                PropertyChanges { target: keyboard; opacity: 0 }
            }]
        transitions: Transition {
            NumberAnimation  {
                duration: 300
                easing.type: Easing.InOutQuad
                properties: "opacity"
            }
        }
    }
}
