import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
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
    property int  tab: 0
    onVisibleChanged: if (root.visible) tab = 0

    // ── Filtered node lists ────────────────────────────────────────
    readonly property var sinkNodes: {
        let nodes = Pipewire.nodes.values
        let out = []
        for (let n of nodes) {
            if (!n || !n.audio || n.isStream) continue
            if (n.isSink && !(n.name ?? "").startsWith("v4l2_")) out.push(n)
        }
        return out
    }

    readonly property var sourceNodes: {
        let nodes = Pipewire.nodes.values
        let out = []
        for (let n of nodes) {
            if (!n || !n.audio || n.isStream || n.isSink) continue
            let name = n.name ?? ""
            let desc = n.description ?? ""
            if (!name.startsWith("v4l2_") && !name.includes(".monitor") && !desc.toLowerCase().includes("monitor")) out.push(n)
        }
        return out
    }

    function nodeLabel(n) {
        if (!n) return "Unknown"
        return n.description || n.nickname || n.name || ("Node " + n.id)
    }

    function isCurrentSink(n) { return Pipewire.defaultAudioSink && n && Pipewire.defaultAudioSink.id === n.id }
    function isCurrentSource(n) { return Pipewire.defaultAudioSource && n && Pipewire.defaultAudioSource.id === n.id }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.requestClose()
    }

    // ── Panel ──────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: 320
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

            // Tabs
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TabBtn { text: "Output"; active: root.tab === 0; onClicked: root.tab = 0; Layout.fillWidth: true }
                TabBtn { text: "Input";  active: root.tab === 1; onClicked: root.tab = 1; Layout.fillWidth: true }
            }

            // Slider Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                property var node: root.tab === 0 ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: parent.node ? (root.tab === 0 ? (parent.node.audio.muted ? "󰖁" : "󰕾") : (parent.node.audio.muted ? "󰍭" : "󰍬")) : "󰝟"
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                        color: parent.node && parent.node.audio.muted ? Colors.mError : Colors.mPrimary
                    }
                    Text {
                        text: parent.node ? Math.round(parent.node.audio.volume * 100) + "%" : "0%"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        color: Colors.mOnSurface
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.tab === 0 ? "MASTER" : "MIC"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        color: Colors.mOutline
                    }
                }

                // Custom Slider
                Rectangle {
                    id: sliderTrack
                    Layout.fillWidth: true
                    height: 32
                    radius: 8
                    color: Colors.mSurfaceVariant
                    clip: true

                    Rectangle {
                        property var node: parent.parent.node
                        width: node ? parent.width * Math.min(node.audio.volume, 1.0) : 0
                        height: parent.height
                        color: node && node.audio.muted ? Colors.mOutline : Colors.mPrimary
                        opacity: 0.3
                        Behavior on width { NumberAnimation { duration: 150 } }
                    }

                    Rectangle {
                        property var node: parent.parent.node
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: node ? parent.width * Math.min(node.audio.volume, 1.0) : 0
                        height: 4
                        radius: 2
                        color: node && node.audio.muted ? Colors.mOutline : Colors.mPrimary
                        Behavior on width { NumberAnimation { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        property var node: parent.parent.node
                        onPressed: if (node) node.audio.volume = Math.max(0, Math.min(1.0, mouse.x / width))
                        onPositionChanged: if (pressed && node) node.audio.volume = Math.max(0, Math.min(1.0, mouse.x / width))
                    }
                }
            }

            // Device List
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "DEVICES"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    color: Colors.mOutline
                    Layout.leftMargin: 4
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Repeater {
                        model: root.tab === 0 ? root.sinkNodes : root.sourceNodes
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 36
                            radius: 6
                            color: isCurrent ? Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.1) : (ma.containsMouse ? Colors.hoverBg(0.3) : "transparent")
                            property bool isCurrent: root.tab === 0 ? root.isCurrentSink(modelData) : root.isCurrentSource(modelData)
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8
                                Text {
                                    text: isCurrent ? "󰄬" : "󰄰"
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: isCurrent ? Colors.mPrimary : Colors.mOutline
                                }
                                Text {
                                    text: root.nodeLabel(modelData)
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: isCurrent ? Colors.mOnSurface : Colors.mOnSurfaceVariant
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (root.tab === 0) Pipewire.preferredDefaultAudioSink = modelData
                                    else Pipewire.preferredDefaultAudioSource = modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component TabBtn: Rectangle {
        property string text: ""
        property bool active: false
        signal clicked
        height: 32
        radius: 8
        color: active ? Colors.mPrimary : (tma.containsMouse ? Colors.hoverBg(0.4) : "transparent")
        Text {
            anchors.centerIn: parent
            text: parent.text
            font.pixelSize: 12
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            color: parent.active ? Colors.mOnPrimary : Colors.mOnSurfaceVariant
        }
        MouseArea { id: tma; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
