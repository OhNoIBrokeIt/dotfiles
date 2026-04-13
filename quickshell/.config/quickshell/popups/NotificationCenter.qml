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

    // Refresh time-ago labels while open
    Timer {
        interval: 30000
        running: root.visible
        repeat: true
        onTriggered: timeRefresh.value++
    }
    property int timeRefresh: 0

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.requestClose()
    }

    // ── Panel ──────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: 380
        x: Math.max(8, Math.min(root.width - width - 8, root.pillCenterX - width / 2))
        y: root.visible ? 64 : 48
        
        implicitHeight: contentCol.implicitHeight + 32
        radius: 12
        color: Qt.rgba(Colors.mSurface.r, Colors.mSurface.g, Colors.mSurface.b, 0.98)
        border.color: Qt.rgba(Colors.mOutline.r, Colors.mOutline.g, Colors.mOutline.b, 0.15)
        border.width: 1
        
        scale: root.visible ? 1 : 0.9
        opacity: root.visible ? 1 : 0
        
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; z: -1 }

        // Top edge highlight
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            height: 1
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        ColumnLayout {
            id: contentCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "NOTIFICATIONS"
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    color: Colors.mPrimary
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: NotificationService.unreadCount + " Unread"
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    color: Colors.mOutline
                }
                Rectangle {
                    width: 1
                    height: 12
                    color: Colors.mOutline
                    opacity: 0.3
                }
                MouseArea {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 20
                    Text {
                        anchors.centerIn: parent
                        text: "Clear"
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                        color: Colors.mError
                    }
                    onClicked: NotificationService.clearAll()
                }
            }

            ListView {
                id: notifList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(400, contentHeight)
                model: NotificationService.notifications
                spacing: 8
                clip: true
                interactive: contentHeight > height

                delegate: Rectangle {
                    width: notifList.width
                    height: 70
                    radius: 8
                    color: Qt.rgba(Colors.mSurfaceVariant.r, Colors.mSurfaceVariant.g, Colors.mSurfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Colors.mOutline.r, Colors.mOutline.g, Colors.mOutline.b, 0.1)
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Rectangle {
                            width: 40; height: 40; radius: 6
                            color: Colors.mSurface
                            Image {
                                anchors.fill: parent
                                source: modelData.image || ""
                                fillMode: Image.PreserveAspectFit
                                visible: source !== ""
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: !parent.children[0].visible
                                text: "󰂚"
                                font.pixelSize: 20
                                color: Colors.mPrimary
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: modelData.summary
                                color: Colors.mOnSurface
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: modelData.body
                                color: Colors.mOnSurfaceVariant
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
