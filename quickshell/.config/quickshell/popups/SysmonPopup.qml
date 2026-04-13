import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

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

    // Data passed in from TopBar
    property int    cpu:         0
    property int    cpuTemp:     0
    property int    gpu:         0
    property int    gpuTemp:     0
    property int    gpuMemUsed:  0
    property int    gpuMemTotal: 0
    property int    ramPct:      0
    property string ramUsed:     ""
    property string ramTotal:    ""

    // ── Click-outside dismissal ────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.requestClose()
    }

    // ── Panel ──────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: 340
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
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing: 14

            // ── CPU ───────────────────────────────────────────────
            StatRow {
                label:   "CPU"
                icon:    "󰻠"
                value:   root.cpu
                detail:  root.cpuTemp + "°C"
                accent:  Colors.mPrimary
            }

            // ── GPU ───────────────────────────────────────────────
            StatRow {
                label:   "GPU"
                icon:    "󰾲"
                value:   root.gpu
                detail:  root.gpuTemp + "°C  " + root.gpuMemUsed + " / " + root.gpuMemTotal + " MiB"
                accent:  Colors.mSecondary
            }

            // ── RAM ───────────────────────────────────────────────
            StatRow {
                label:   "RAM"
                icon:    "󰘚"
                value:   root.ramPct
                detail:  root.ramUsed + " / " + root.ramTotal + " GiB"
                accent:  Colors.mTertiary
            }
        }
    }

    // ── StatRow component ──────────────────────────────────────────
    component StatRow: ColumnLayout {
        property string label:  ""
        property string icon:   ""
        property int    value:  0
        property string detail: ""
        property color  accent: Colors.mPrimary

        Layout.fillWidth: true
        spacing: 6

        // Label row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: parent.parent.icon
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                color: parent.parent.accent
            }
            Text {
                text: parent.parent.label
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                color: Colors.mOnSurface
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: parent.parent.value + "%"
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                color: parent.parent.accent
                font.bold: true
            }
            Text {
                text: parent.parent.detail
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                color: Colors.mOnSurfaceVariant
            }
        }

        // Progress bar
        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Qt.rgba(Colors.mOnSurface.r, Colors.mOnSurface.g, Colors.mOnSurface.b, 0.1)

            Rectangle {
                width: Math.min(parent.width * parent.parent.value / 100, parent.width)
                height: parent.height
                radius: parent.radius
                color: parent.parent.accent
                
                // Subtle glow on progress bars
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: parent.parent.accent
                    opacity: 0.3
                    scale: 1.05
                    z: -1
                }
                
                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
        }
    }
}
