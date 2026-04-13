import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../theme"
import "../services"

Item {
    id: root
    opacity: 1.0

    property var modelData: null
    property var barScreen: null

    readonly property var activePlayer: MediaService.activePlayer

    property bool weatherOpen: false
    property real weatherPillCenterX: 0

    property bool mediaOpen: false
    property real mediaPillCenterX: 0

    property bool volumeOpen: false
    property real volumePillCenterX: 0

    property bool launcherOpen: false

    property bool notifOpen: false
    property real notifPillCenterX: 0

    property bool ccOpen: false
    property real rightPillCenterX: 0

    property bool isOled: modelData ? modelData.name === "DP-2" : false

    property bool sysmonOpen: false
    property real sysmonPillCenterX: 0

    property int sysCpu: 0
    property int sysCpuTemp: 0
    property int sysGpu: 0
    property int sysGpuTemp: 0
    property int sysGpuMemUsed: 0
    property int sysGpuMemTotal: 0
    property int sysRamPct: 0
    property string sysRamUsed: "0"
    property string sysRamTotal: "0"

    readonly property string audioDevice: {
        if (!AudioService) return "Audio"
        return AudioService.displayDevice !== "" ? AudioService.displayDevice : (AudioService.deviceName || "Audio")
    }
    readonly property string audioRate: AudioService ? AudioService.sampleRate : ""
    readonly property string audioFormat: AudioService ? AudioService.sampleFormat : ""
    readonly property string audioSummary: {
        if (!AudioService) return "Connecting..."
        if (AudioService.muted)
            return "Muted";
        if (audioRate !== "")
            return audioRate + (audioFormat !== "" ? " • " + audioFormat : "");
        return audioDevice;
    }

    readonly property string weatherIcon: (WeatherService && WeatherService.ready)
        ? WeatherService.weatherIcon(WeatherService.weatherCode, WeatherService.isDay)
        : "󰖐"

    readonly property string weatherSummary: (WeatherService && WeatherService.ready)
        ? (Math.round(WeatherService.temperature) + "°")
        : "--°"

    readonly property string weatherDetail: (WeatherService && WeatherService.ready)
        ? WeatherService.conditionText(WeatherService.weatherCode)
        : "Weather"

    onActivePlayerChanged: if (!activePlayer) mediaOpen = false

    function startSysmon() {
        if (!sysmonProc.running)
            sysmonProc.running = true
    }

    Process {
        id: sysmonProc
        command: [Quickshell.shellDir + "/scripts/sysmon.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim())
                    root.sysCpu = data.cpu ?? 0
                    root.sysCpuTemp = data.cpu_temp ?? 0
                    root.sysGpu = data.gpu ?? 0
                    root.sysGpuTemp = data.gpu_temp ?? 0
                    root.sysGpuMemUsed = data.gpu_mem_used ?? 0
                    root.sysGpuMemTotal = data.gpu_mem_total ?? 0
                    root.sysRamPct = data.ram_pct ?? 0
                    root.sysRamUsed = data.ram_used ?? "0"
                    root.sysRamTotal = data.ram_total ?? "0"
                } catch (e) {
                    console.log("sysmon parse failed:", e)
                }
            }
        }
    }

    Timer {
        id: sysmonTimer
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.startSysmon()
    }

    // ── CONTENT ────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 14

        // LEFT SECTION
        RowLayout {
            spacing: 8
            ClickPill {
                id: workspacePill
                accent: Colors.mPrimary
                contentItem: Row {
                    spacing: 10
                    anchors.centerIn: parent
                    Repeater {
                        model: 10
                        delegate: Rectangle {
                            width: active ? 14 : 6
                            height: 6
                            radius: 3
                            color: active ? Colors.mPrimary : Qt.rgba(Colors.mOnSurface.r, Colors.mOnSurface.g, Colors.mOnSurface.b, 0.25)
                            property bool active: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === index + 1 : false
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                }
            }

            ClickPill {
                id: launcherPill
                text: "󰣇"
                compact: true
                accent: Colors.mTertiary
                onClicked: root.launcherOpen = !root.launcherOpen
            }

            ClickPill {
                id: weatherPill
                accent: Colors.mSecondary
                onClicked: {
                    root.weatherPillCenterX = weatherPill.mapToItem(root, weatherPill.width / 2, 0).x
                    root.weatherOpen = !root.weatherOpen
                }
                contentItem: Row {
                    spacing: 8
                    anchors.centerIn: parent
                    Text { text: root.weatherIcon; color: Colors.mSecondary; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font" }
                    Text { text: root.weatherSummary; color: Colors.mOnSurface; font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    Text { text: root.weatherDetail; color: Colors.mOnSurfaceVariant; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; opacity: 0.8 }
                }
            }

            ClickPill {
                id: mediaPill
                visible: MediaService.hasPlayer
                accent: Colors.mPrimary
                onClicked: {
                    root.mediaPillCenterX = mediaPill.mapToItem(root, mediaPill.width / 2, 0).x
                    root.mediaOpen = !root.mediaOpen
                }
                contentItem: Row {
                    spacing: 8
                    anchors.centerIn: parent
                    Text { text: "󰎈"; color: Colors.mPrimary; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font" }
                    Text {
                        text: MediaService.title
                        color: Colors.mOnSurface
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, 180)
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // CENTER (Clock)
        ClickPill {
            id: clockPill
            accent: Colors.mPrimary
            contentItem: Row {
                spacing: 8
                anchors.centerIn: parent
                Text { text: "󰃭"; color: Colors.mPrimary; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font" }
                Text { id: timeLabel; color: Colors.mOnSurface; font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                Text { id: dateLabel; color: Colors.mOnSurfaceVariant; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; opacity: 0.8 }
                Timer {
                    interval: 1000; running: true; repeat: true; triggeredOnStart: true
                    onTriggered: {
                        let d = new Date()
                        timeLabel.text = d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })
                        dateLabel.text = d.toLocaleDateString([], { month: 'numeric', day: 'numeric', year: '2-digit' }).replace(/\//g, '.')
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // RIGHT SECTION
        RowLayout {
            spacing: 8
            ClickPill {
                id: sysmonPill
                accent: Colors.mSecondary
                onClicked: {
                    root.sysmonPillCenterX = sysmonPill.mapToItem(root, sysmonPill.width / 2, 0).x
                    root.sysmonOpen = !root.sysmonOpen
                }
                contentItem: Row {
                    spacing: 12
                    StatBadge { label: "CPU"; value: root.sysCpu + "%"; dim: root.sysCpuTemp + "°" }
                    StatBadge { label: "GPU"; value: root.sysGpu + "%"; dim: root.sysGpuTemp + "°" }
                    StatBadge { label: "RAM"; value: root.sysRamPct + "%"; dim: root.sysRamUsed + "G" }
                }
            }

            ClickPill {
                id: audioPill
                accent: AudioService.muted ? Colors.mError : Colors.mPrimary
                onClicked: {
                    root.volumePillCenterX = audioPill.mapToItem(root, audioPill.width / 2, 0).x
                    root.volumeOpen = !root.volumeOpen
                }
                onMiddleClicked: AudioService.toggleMute()
                onScroll: (delta) => AudioService.setVolume(AudioService.volume + (delta > 0 ? 0.02 : -0.02))
                contentItem: Row {
                    spacing: 8
                    Text { text: AudioService.muted ? "󰖁" : "󰕾"; color: AudioService.muted ? Colors.mError : Colors.mPrimary; font.pixelSize: 15 }
                    Text { text: Math.round(AudioService.volume * 100) + "%"; color: Colors.mOnSurface; font.pixelSize: 13; font.bold: true }
                    Text { text: root.audioSummary; color: Colors.mOnSurfaceVariant; font.pixelSize: 11; elide: Text.ElideRight; width: 100; opacity: 0.8 }
                }
            }

            ClickPill {
                id: notifPill
                text: "󰂚"
                compact: true
                accent: NotificationService.unreadCount > 0 ? Colors.mPrimary : Colors.mSecondary
                onClicked: {
                    root.notifPillCenterX = notifPill.mapToItem(root, notifPill.width / 2, 0).x
                    root.notifOpen = !root.notifOpen
                }
            }

            ClickPill {
                id: ccPill
                text: "󰒓"
                compact: true
                accent: Colors.mTertiary
                onClicked: {
                    root.rightPillCenterX = ccPill.mapToItem(root, ccPill.width / 2, 0).x
                    root.ccOpen = !root.ccOpen
                }
            }
        }
    }

    component ClickPill: Rectangle {
        id: pill
        property alias text: label.text
        property color accent: Colors.mPrimary
        property alias contentItem: innerLoader.sourceComponent
        property bool compact: false
        signal clicked
        signal middleClicked
        signal scroll(int delta)

        radius: 10 // Sleek technical rounding
        height: 34
        
        // Standalone background with increased transparency
        color: mouse.containsMouse 
            ? Qt.rgba(Colors.mSurfaceVariant.r, Colors.mSurfaceVariant.g, Colors.mSurfaceVariant.b, 0.85)
            : Qt.rgba(Colors.mSurface.r, Colors.mSurface.g, Colors.mSurface.b, 0.75)
            
        border.color: mouse.containsMouse ? accent : Qt.rgba(accent.r, accent.g, accent.b, 0.15)
        border.width: 1

        scale: mouse.containsMouse ? 1.05 : 1.0
        y: mouse.containsMouse ? -1 : 0
        implicitWidth: compact ? (loadedItem ? loadedItem.implicitWidth + 18 : plainText.implicitWidth + 18) : (loadedItem ? loadedItem.implicitWidth + 24 : plainText.implicitWidth + 28)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

        // Outer Glow Shadow (ColorShell style)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.color: accent
            border.width: 2
            opacity: mouse.containsMouse ? 0.15 : 0.04
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        // Top edge highlight for 3D depth
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.08)
        }

        Loader { id: innerLoader; anchors.centerIn: parent; active: sourceComponent !== undefined && sourceComponent !== null }
        readonly property Item loadedItem: innerLoader.item

        Text {
            id: plainText; visible: !innerLoader.active; anchors.centerIn: parent
            color: mouse.containsMouse ? accent : Colors.mOnSurface
            font { pixelSize: 14; family: "JetBrainsMono Nerd Font"; bold: mouse.containsMouse; letterSpacing: 0.5 }
            text: label.text
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        Text { id: label; visible: false }
        MouseArea {
            id: mouse; anchors.fill: parent; hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: (mouse) => { if (mouse.button === Qt.MiddleButton) pill.middleClicked(); else pill.clicked() }
            onWheel: (wheel) => pill.scroll(wheel.angleDelta.y)
        }
    }

    component StatBadge: Row {
        property string label: ""; property string value: ""; property string dim: ""
        spacing: 4
        Text { 
            text: parent.label
            color: Colors.mOnSurfaceVariant
            font { pixelSize: 9; bold: true; family: "JetBrainsMono Nerd Font" }
            opacity: 0.7
            anchors.baseline: vTxt.baseline 
        }
        Text { 
            id: vTxt
            text: parent.value
            color: Colors.mPrimary
            font { pixelSize: 13; bold: true; family: "JetBrainsMono Nerd Font" }
        }
        Text { 
            text: parent.dim
            color: Colors.mOnSurfaceVariant
            font { pixelSize: 10; family: "JetBrainsMono Nerd Font" }
            opacity: 0.6
            anchors.baseline: vTxt.baseline 
        }
    }
}
