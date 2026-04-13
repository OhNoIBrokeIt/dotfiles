import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    anchors { top: true; left: true; right: true; bottom: true }

    property bool isOpen: false
    visible: isOpen
    color: "transparent"

    signal requestClose

    property real pillCenterX: 0

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.requestClose()
    }

    Rectangle {
        id: panel
        width: 300
        x: Math.max(8, Math.min(root.width - width - 8, root.pillCenterX - width / 2))
        y: root.visible ? 64 : 48
        
        implicitHeight: contentCol.implicitHeight + 32
        radius: 12
        color: Qt.rgba(Colors.mSurface.r, Colors.mSurface.g, Colors.mSurface.b, 0.88)
        border.color: Qt.rgba(Colors.mOutline.r, Colors.mOutline.g, Colors.mOutline.b, 0.15)
        border.width: 1
        
        scale: root.visible ? 1 : 0.9
        opacity: root.visible ? 1 : 0
        
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; z: -1 }

        // Subtle Glow Shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.color: Colors.mSecondary
            border.width: 4
            opacity: 0.06
            z: -1
        }

        // Top edge highlight
        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2
            height: 1; radius: parent.radius; color: Qt.rgba(1, 1, 1, 0.12)
        }

        ColumnLayout {
            id: contentCol
            anchors {
                top: parent.top; topMargin: 16
                left: parent.left; leftMargin: 16
                right: parent.right; rightMargin: 16
            }
            spacing: 20

            // Current Weather Display
            RowLayout {
                spacing: 16
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: WeatherService.weatherIcon(WeatherService.weatherCode, WeatherService.isDay)
                    color: Colors.mSecondary
                    font.pixelSize: 48
                    font.family: "JetBrainsMono Nerd Font"
                }

                ColumnLayout {
                    spacing: 0
                    Text {
                        text: Math.round(WeatherService.temperature) + "°C"
                        color: Colors.mOnSurface
                        font.pixelSize: 32
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: WeatherService.conditionText(WeatherService.weatherCode)
                        color: Colors.mOnSurfaceVariant
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // Location Info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "LOCATION"
                    color: Colors.mSecondary
                    font.pixelSize: 10
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    font.letterSpacing: 1
                }
                
                Text {
                    text: WeatherService.locationName
                    color: Colors.mOnSurface
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Search Box
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 6
                    color: Colors.mSurfaceVariant
                    border.color: searchInput.activeFocus ? Colors.mSecondary : Qt.rgba(Colors.mOutline.r, Colors.mOutline.g, Colors.mOutline.b, 0.2)
                    border.width: 1

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colors.mOnSurface
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        
                        Text {
                            text: "Search location..."
                            color: Colors.mOutline
                            visible: !parent.text && !parent.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                            font: parent.font
                        }

                        onAccepted: {
                            WeatherService.searchLocation(text)
                            text = ""
                            root.requestClose()
                        }
                    }
                }
                
                Text {
                    text: "Press Enter to search"
                    color: Colors.mOutline
                    font.pixelSize: 10
                    font.italic: true
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}
