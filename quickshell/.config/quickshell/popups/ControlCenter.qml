import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
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

    property string userName: ""
    property string hostName: ""
    property string avatarPath: ""

    readonly property var sinkNodes: {
        let nodes = Pipewire.nodes.values
        let out = []
        for (let n of nodes) {
            if (!n || !n.audio || n.isStream || !n.isSink) continue
            if ((n.name ?? "").startsWith("v4l2_")) continue
            out.push(n)
        }
        return out
    }

    Process {
        id: userInfoProc
        command: ["bash", "-c", "printf '%s\\n%s\\n%s' \"$USER\" \"$(hostname)\" \"$HOME\""]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("\n")
                root.userName = parts[0] ?? ""
                root.hostName = parts[1] ?? ""
                let home = parts[2] ?? ""
                root.avatarPath = home + "/.face"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.requestClose()
    }

    // ── Panel ──────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: 360
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
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2
            height: 1; radius: parent.radius; color: Qt.rgba(1, 1, 1, 0.12)
        }

        ColumnLayout {
            id: contentCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
            spacing: 24

            // Header Section
            RowLayout {
                spacing: 16
                Rectangle {
                    width: 54; height: 54; radius: 27
                    color: Colors.mSurfaceVariant
                    border.color: Colors.mPrimary; border.width: 1
                    clip: true
                    Image {
                        anchors.fill: parent; source: "file://" + root.avatarPath
                        fillMode: Image.PreserveAspectCrop
                    }
                }
                ColumnLayout {
                    spacing: 0
                    Text {
                        text: root.userName.toUpperCase()
                        color: Colors.mOnSurface
                        font.pixelSize: 18
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        font.letterSpacing: 1
                    }
                    Text {
                        text: root.hostName
                        color: Colors.mPrimary
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        opacity: 0.8
                    }
                }
            }

            // Quick Toggle Grid (AxShell Style)
            GridLayout {
                columns: 2; columnSpacing: 12; rowSpacing: 12
                Layout.fillWidth: true

                QuickToggle {
                    Layout.fillWidth: true
                    icon: AudioService.muted ? "󰖁" : "󰕾"
                    label: "Speaker"
                    active: !AudioService.muted
                    accent: Colors.mPrimary
                    onClicked: AudioService.toggleMute()
                }

                QuickToggle {
                    Layout.fillWidth: true
                    icon: AudioService.micMuted ? "󰍭" : "󰍬"
                    label: "Microphone"
                    active: !AudioService.micMuted
                    accent: Colors.mSecondary
                    onClicked: AudioService.toggleMicMute()
                }
            }

            // Audio Device List
            ColumnLayout {
                Layout.fillWidth: true; spacing: 8
                Text {
                    text: "AUDIO OUTPUT"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    font.letterSpacing: 1
                    color: Colors.mOutline; opacity: 0.8
                }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Repeater {
                        model: root.sinkNodes
                        delegate: DeviceBtn {
                            text: nLabel(modelData)
                            active: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.id === modelData.id
                            onClicked: Pipewire.preferredDefaultAudioSink = modelData
                        }
                    }
                }
            }

            // Power Section (Dank / Noctalia style)
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                PowerBtn { icon: "󰐥"; label: "OFF"; accent: Colors.mError; onClicked: powerAction.cmd = ["poweroff"] }
                PowerBtn { icon: "󰜉"; label: "REBOOT"; accent: Colors.mSecondary; onClicked: powerAction.cmd = ["reboot"] }
                PowerBtn { icon: "󰤄"; label: "SLEEP"; accent: Colors.mTertiary; onClicked: powerAction.cmd = ["systemctl", "suspend"] }
                PowerBtn { icon: "󰗽"; label: "EXIT"; accent: Colors.mPrimary; onClicked: powerAction.cmd = ["hyprctl", "dispatch", "exit"] }
            }
        }
    }

    Process { id: powerAction; property var cmd: []; command: cmd; onCmdChanged: if (cmd.length > 0) running = true }

    function nLabel(n) { return n ? (n.description || n.nickname || n.name) : "Unknown" }

    component QuickToggle: Rectangle {
        property string icon: ""
        property string label: ""
        property bool active: false
        property color accent: Colors.mPrimary
        signal clicked
        height: 64; radius: 12
        color: active ? Qt.rgba(accent.r, accent.g, accent.b, 0.15) : Qt.rgba(Colors.mSurfaceVariant.r, Colors.mSurfaceVariant.g, Colors.mSurfaceVariant.b, 0.25)
        border.color: active ? accent : "transparent"; border.width: 1
        
        RowLayout {
            anchors.fill: parent; anchors.margins: 14; spacing: 12
            Text { text: parent.parent.icon; font.pixelSize: 22; color: parent.parent.active ? parent.parent.accent : Colors.mOnSurface; font.family: "JetBrainsMono Nerd Font" }
            Text { text: parent.parent.label; font.pixelSize: 13; font.bold: true; color: Colors.mOnSurface; Layout.fillWidth: true }
        }
        MouseArea { anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    component PowerBtn: ColumnLayout {
        property string icon: ""
        property string label: ""
        property color accent: Colors.mPrimary
        signal clicked
        spacing: 6; Layout.fillWidth: true
        Rectangle {
            Layout.alignment: Qt.AlignHCenter; width: 54; height: 54; radius: 27
            color: pma.containsMouse ? Qt.rgba(accent.r, accent.g, accent.b, 0.2) : Qt.rgba(Colors.mSurfaceVariant.r, Colors.mSurfaceVariant.g, Colors.mSurfaceVariant.b, 0.25)
            border.color: pma.containsMouse ? accent : "transparent"; border.width: 1
            Text { anchors.centerIn: parent; text: parent.parent.icon; font.pixelSize: 22; color: pma.containsMouse ? parent.parent.accent : Colors.mOnSurface; font.family: "JetBrainsMono Nerd Font" }
            MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; onClicked: parent.parent.clicked() }
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        Text { Layout.alignment: Qt.AlignHCenter; text: parent.label; font.pixelSize: 9; font.bold: true; color: Colors.mOutline; opacity: 0.7 }
    }

    component DeviceBtn: Rectangle {
        property string text: ""
        property bool active: false
        signal clicked
        height: 38; radius: 8; Layout.fillWidth: true
        color: active ? Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.12) : (dma.containsMouse ? Colors.hoverBg(0.3) : "transparent")
        RowLayout {
            anchors.fill: parent; anchors.margins: 12; spacing: 10
            Text { text: parent.parent.active ? "󰄬" : "󰄰"; color: parent.parent.active ? Colors.mPrimary : Colors.mOutline; font.family: "JetBrainsMono Nerd Font" }
            Text { text: parent.parent.text; color: parent.parent.active ? Colors.mOnSurface : Colors.mOnSurfaceVariant; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
        }
        MouseArea { id: dma; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
    }
}
