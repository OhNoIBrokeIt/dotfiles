import QtQuick
import QtQuick.Layouts
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
    property real currentPos: 0

    Timer {
        interval: 500
        running: root.visible && MediaService.hasPlayer
        repeat: true
        triggeredOnStart: true
        onTriggered: root.currentPos = MediaService.activePlayer?.position ?? 0
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.requestClose()
    }

    Rectangle {
        id: panel
        width: 320
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
            border.color: Colors.mPrimary
            border.width: 4
            opacity: 0.06
            z: -1
        }

        // Top edge highlight
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            height: 1
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.12)
        }

        ColumnLayout {
            id: contentCol
            anchors {
                top: parent.top; topMargin: 16
                left: parent.left; leftMargin: 16
                right: parent.right; rightMargin: 16
            }
            spacing: 16

            Rectangle {
                id: artWork
                Layout.fillWidth: true
                implicitHeight: width
                radius: 8
                clip: true
                color: Colors.mSurfaceVariant
                border.color: Qt.rgba(Colors.mOutline.r, Colors.mOutline.g, Colors.mOutline.b, 0.3)
                border.width: 1

                Image {
                    anchors.fill: parent
                    source: MediaService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    opacity: source !== "" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                Rectangle {
                    anchors.fill: parent
                    visible: MediaService.artUrl === ""
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "󰎈"
                        font.pixelSize: 64
                        font.family: "JetBrainsMono Nerd Font"
                        color: Colors.mPrimary
                        opacity: 0.5
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: MediaService.title || "No Media"
                    color: Colors.mOnSurface
                    font.pixelSize: 18
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: MediaService.artist || "Unknown Artist"
                    color: Colors.mPrimary
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    id: progressTrack
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Qt.rgba(Colors.mOnSurface.r, Colors.mOnSurface.g, Colors.mOnSurface.b, 0.1)

                    Rectangle {
                        id: progressBar
                        width: {
                            const len = MediaService.length
                            return len > 0
                                ? Math.min(parent.width * (root.currentPos / len), parent.width)
                                : 0
                        }
                        height: parent.height
                        radius: parent.radius
                        color: Colors.mPrimary
                        
                        // Glow on progress bar
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Colors.mPrimary
                            opacity: 0.4
                            scale: 1.05
                            z: -1
                        }

                        Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function(mouse) {
                            const len = MediaService.length
                            if (len > 0 && MediaService.canSeek)
                                MediaService.activePlayer.position = len * (mouse.x / parent.width)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: formatTime(root.currentPos)
                        color: Colors.mOnSurfaceVariant
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: formatTime(MediaService.length)
                        color: Colors.mOnSurfaceVariant
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 8
                spacing: 12

                ControlBtn {
                    text: "󰒮"
                    Layout.fillWidth: true
                    canActivate: MediaService.canGoPrevious
                    onClicked: MediaService.previous()
                }

                ControlBtn {
                    text: MediaService.isPlaying ? "󰏤" : "󰐊"
                    Layout.fillWidth: true
                    accent: Colors.mSecondary
                    iconSize: 32
                    canActivate: MediaService.canPlayPause
                    onClicked: MediaService.togglePlaying()
                }

                ControlBtn {
                    text: "󰒭"
                    Layout.fillWidth: true
                    canActivate: MediaService.canGoNext
                    onClicked: MediaService.next()
                }
            }
        }
    }

    component ControlBtn: Rectangle {
        id: btn
        property alias text: label.text
        property bool canActivate: true
        property int iconSize: 24
        property color accent: Colors.mPrimary
        signal clicked

        implicitHeight: 44
        radius: 8
        color: area.containsMouse && canActivate 
            ? Qt.rgba(accent.r, accent.g, accent.b, 0.2)
            : Qt.rgba(Colors.mSurfaceVariant.r, Colors.mSurfaceVariant.g, Colors.mSurfaceVariant.b, 0.3)
            
        border.color: area.containsMouse && canActivate ? accent : "transparent"
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Text {
            id: label
            anchors.centerIn: parent
            font.pixelSize: parent.iconSize
            font.family: "JetBrainsMono Nerd Font"
            color: parent.canActivate ? (area.containsMouse ? accent : Colors.mOnSurface) : Colors.mOutline
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (parent.canActivate) parent.clicked()
        }
    }

    function formatTime(secs) {
        let s = Math.floor(secs ?? 0)
        let m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + String(s).padStart(2, "0")
    }
}
