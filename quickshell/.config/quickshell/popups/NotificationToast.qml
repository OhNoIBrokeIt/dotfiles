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
    anchors { top: true; left: true; right: true }

    color: "transparent"
    implicitHeight: 64 + 16 + 180      // bar + gap + max toast height

    visible: toast.opacity > 0

    property bool active: true
    property var currentEntry: null
    property var current: currentEntry?.notif ?? null

    // ── Timer state ────────────────────────────────────────────────
    property int totalMs:     5000
    property real progress:   1.0   // 1 = full, 0 = expired

    Connections {
        target: NotificationService
        function onNewNotification(entry) {
            if (!root.active) return
            root.currentEntry = entry
            let ms = (entry.notif.expireTimeout > 0 ? entry.notif.expireTimeout : 5000)
            root.totalMs   = ms
            root.progress  = 1.0
            progressAnim.restart()
            toast.opacity = 1
            hideTimer.interval = ms
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        onTriggered: toast.opacity = 0
    }

    // Progress bar drains over the notification lifetime
    NumberAnimation {
        id: progressAnim
        target: root
        property: "progress"
        from: 1.0
        to: 0.0
        duration: root.totalMs
        easing.type: Easing.Linear
    }

    // ── Toast card ─────────────────────────────────────────────────
    Rectangle {
        id: toast
        width: 420
        anchors {
            top: parent.top
            topMargin: 64 + 12
            horizontalCenter: parent.horizontalCenter
        }
        height: inner.implicitHeight + 24 + 4   // padding + progress strip
        radius: 16
        color: Colors.pillBg(0.98)
        border.color: Qt.rgba(0, 0, 0, 0.22)
        border.width: 1
        opacity: 0
        clip: true

        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        transform: Translate {
            y: toast.opacity < 1 ? -10 : 0
            Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: { hideTimer.stop(); progressAnim.stop(); toast.opacity = 0 }
        }

        // ── Urgency accent strip (left edge) ──────────────────────
        Rectangle {
            width: 3
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; bottomMargin: 4 }
            radius: 2
            color: {
                let u = root.current?.urgency ?? 1
                if (u === 2) return Colors.mError
                if (u === 0) return Colors.mOnSurfaceVariant
                return Colors.mPrimary
            }
        }

        // ── Main content ──────────────────────────────────────────
        ColumnLayout {
            id: inner
            anchors {
                top: parent.top; topMargin: 12
                left: parent.left; leftMargin: 16
                right: parent.right; rightMargin: 12
            }
            spacing: 0

            // Header row: app icon + app name + close
            RowLayout {
                Layout.fillWidth: true
                spacing: 7

                Image {
                    width: 16; height: 16
                    source: root.current?.appIcon ? "image://icon/" + root.current.appIcon : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: source !== ""
                }
                Text {
                    text: root.current?.appName ?? ""
                    color: Colors.mOnSurfaceVariant
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: "󰅖"
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    color: Colors.mOnSurfaceVariant

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        onClicked: { hideTimer.stop(); progressAnim.stop(); toast.opacity = 0 }
                    }
                }
            }

            // Body row: optional image thumbnail + text
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 12
                visible: (root.current?.summary ?? "") !== "" || (root.current?.body ?? "") !== ""

                // Notification image (when present)
                Rectangle {
                    visible: thumbImg.source !== ""
                    width: 56; height: 56
                    radius: 10
                    clip: true
                    color: Colors.mSurfaceVariant
                    Layout.alignment: Qt.AlignTop

                    Image {
                        id: thumbImg
                        anchors.fill: parent
                        source: root.current?.image ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                // Summary + body
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: root.current?.summary ?? ""
                        color: Colors.mOnSurface
                        font.pixelSize: 14
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        elide: Text.ElideRight
                        visible: text !== ""
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.current?.body ?? ""
                        color: Colors.mOnSurfaceVariant
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: text !== ""
                    }
                }
            }

            // Actions
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 6
                visible: (root.current?.actions?.length ?? 0) > 0

                Repeater {
                    model: root.current?.actions ?? []
                    delegate: Rectangle {
                        required property var modelData
                        implicitHeight: 28
                        Layout.fillWidth: true
                        radius: 7
                        color: actionArea.containsMouse
                            ? Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.28)
                            : Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.14)
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent
                            text: modelData.text
                            color: Colors.mPrimary
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            id: actionArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                modelData.invoke()
                                hideTimer.stop()
                                progressAnim.stop()
                                toast.opacity = 0
                            }
                        }
                    }
                }
            }
        }

        // ── Timer progress strip (bottom of card) ─────────────────
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 4
            radius: 0
            color: "transparent"

            Rectangle {
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: parent.width * root.progress
                radius: 0
                color: {
                    let u = root.current?.urgency ?? 1
                    if (u === 2) return Colors.mError
                    if (u === 0) return Colors.mOnSurfaceVariant
                    return Colors.mPrimary
                }
                // Bottom corners follow card radius, top stays flat
                layer.enabled: false
            }
        }
    }
}
