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

    // Not interactive — no background MouseArea
    color: "transparent"
    visible: osd.opacity > 0

    property real pillCenterX: 0
    property bool popupOpen: false   // suppress OSD while the full popup is open

    // ── Trigger on any volume/mute change ─────────────────────────
    Connections {
        target: AudioService
        function onVolumeChanged() { root._show() }
        function onMutedChanged()  { root._show() }
    }

    function _show() {
        if (root.popupOpen) return
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: osd.opacity = 0
        onRunningChanged: if (running) osd.opacity = 1
    }

    // ── OSD panel ──────────────────────────────────────────────────
    Rectangle {
        id: osd
        width: 220
        height: 52
        x: Math.max(8, Math.min(root.width - width - 8, root.pillCenterX - width / 2))
        y: 72
        radius: 16
        color: Colors.pillBg(0.95)
        border.color: Colors.borderCol()
        border.width: 1
        opacity: 0

        Behavior on opacity { NumberAnimation { duration: 150 } }

        RowLayout {
            anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
            spacing: 10

            // Icon
            Text {
                text: {
                    if (AudioService.muted || AudioService.volume <= 0) return "󰝟"
                    if (AudioService.volume < 0.34) return "󰕿"
                    if (AudioService.volume < 0.67) return "󰖀"
                    return "󰕾"
                }
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                color: AudioService.muted ? Colors.mError : Colors.mPrimary
            }

            // Bar
            Rectangle {
                Layout.fillWidth: true
                height: 5
                radius: 3
                color: Colors.mSurfaceVariant

                Rectangle {
                    width: AudioService.muted ? 0 : Math.min(parent.width * AudioService.volume, parent.width)
                    height: parent.height
                    radius: parent.radius
                    color: Colors.mPrimary
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }

            // Percentage
            Text {
                text: AudioService.muted ? "Muted" : Math.round(AudioService.volume * 100) + "%"
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
                color: AudioService.muted ? Colors.mError : Colors.mOnSurface
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
