import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors { top: true; left: true; right: true; bottom: true }

    property bool isOpen: false
    visible: isOpen
    color: "transparent"

    signal requestClose

    onVisibleChanged: {
        if (visible) {
            searchInput.forceActiveFocus()
            scanner.running = true
        } else {
            searchInput.text = ""
        }
    }

    // ── App Scanner ────────────────────────────────────────────────
    ListModel { id: appModel }
    ListModel { id: filteredModel }

    Process {
        id: scanner
        command: ["bash", "-c", "grep -hE '^(Name|Exec|Icon)=' /usr/share/applications/*.desktop"]
        stdout: StdioCollector {
            onStreamFinished: {
                appModel.clear()
                let lines = text.split("\n")
                let currentApp = {}
                for (let line of lines) {
                    if (line.startsWith("Name=")) currentApp.name = line.substring(5)
                    else if (line.startsWith("Exec=")) currentApp.exec = line.substring(5).split(" %")[0]
                    else if (line.startsWith("Icon=")) currentApp.icon = line.substring(5)
                    
                    if (currentApp.name && currentApp.exec && currentApp.icon) {
                        appModel.append(currentApp)
                        currentApp = {}
                    }
                }
                filterApps("")
            }
        }
    }

    function filterApps(query) {
        filteredModel.clear()
        let q = query.toLowerCase()
        for (let i = 0; i < appModel.count; i++) {
            let app = appModel.get(i)
            if (q === "" || app.name.toLowerCase().includes(q)) {
                filteredModel.append(app)
            }
            if (filteredModel.count >= 8) break
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.requestClose()
    }

    Rectangle {
        id: panel
        width: 440
        x: 12
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
            anchors.fill: parent; anchors.margins: -4; radius: parent.radius + 4
            color: "transparent"; border.color: Colors.mPrimary; border.width: 4; opacity: 0.06; z: -1
        }

        // Top edge highlight
        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2
            height: 1; radius: parent.radius; color: Qt.rgba(1, 1, 1, 0.12)
        }

        ColumnLayout {
            id: contentCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing: 12

            Text {
                text: "LAUNCHER"
                font { pixelSize: 10; bold: true; family: "JetBrainsMono Nerd Font"; letterSpacing: 1 }
                color: Colors.mPrimary
            }

            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 8
                color: Colors.mSurfaceVariant
                border.color: searchInput.activeFocus ? Colors.mPrimary : "transparent"
                border.width: 1
                
                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    font { family: "JetBrainsMono Nerd Font"; pixelSize: 14 }
                    color: Colors.mOnSurface
                    
                    Text {
                        text: "Search applications..."
                        color: Colors.mOutline
                        visible: !parent.text && !parent.activeFocus
                        anchors.verticalCenter: parent.verticalCenter
                        font: parent.font
                    }

                    onTextChanged: filterApps(text)
                    onAccepted: if (filteredModel.count > 0) launchApp(filteredModel.get(0).exec)
                }
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                model: filteredModel
                spacing: 4
                clip: true

                delegate: Rectangle {
                    width: appList.width
                    height: 40
                    radius: 6
                    color: ma.containsMouse ? Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.1) : "transparent"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12
                        
                        Text {
                            text: "󰀻" // Icon placeholder
                            font.pixelSize: 18
                            color: Colors.mPrimary
                        }

                        Text {
                            text: model.name
                            color: ma.containsMouse ? Colors.mOnSurface : Colors.mOnSurfaceVariant
                            font { pixelSize: 13; family: "JetBrainsMono Nerd Font"; bold: ma.containsMouse }
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: launchApp(model.exec)
                    }
                }
            }
        }
    }

    function launchApp(exec) {
        launcherAction.command = ["bash", "-c", exec + " &"]
        launcherAction.running = true
        root.requestClose()
    }

    Process { id: launcherAction }
}
