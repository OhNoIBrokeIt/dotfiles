import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtCore
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Services.Mpris
import "../theme"
import "../services"

// WlSessionLock takes over all outputs — one surface per screen
WlSessionLock {
    id: lock

    // Lock/unlock driven by loginctl signals via shell.qml
    locked: false

    surface: WlSessionLockSurface {
        id: surface

        // ── State ──────────────────────────────────────────────────
        property bool authenticating: false
        property bool failed:         false
        property string inputText:    ""

        // ── MPRIS — pick first playing, fallback to first available ─
        property MprisPlayer activePlayer: {
            for (let i = 0; i < Mpris.players.count; i++) {
                let p = Mpris.players.values[i]
                if (p.isPlaying) return p
            }
            return Mpris.players.count > 0 ? Mpris.players.values[0] : null
        }
        property bool hasMedia: activePlayer !== null

        // MPRIS position doesn't self-update — poll it
        property real mediaPos: 0
        Timer {
            interval: 500
            running: surface.hasMedia
            repeat: true
            triggeredOnStart: true
            onTriggered: surface.mediaPos = surface.activePlayer?.position ?? 0
        }

        // ── PAM ────────────────────────────────────────────────────
        PamContext {
            id: pam
            config: "hyprlock"

            onPamMessage: {
                if (pam.responseRequired) pam.respond(surface.inputText)
            }

            onCompleted: function(result) {
                if (result === PamResult.Success) {
                    surface.failed         = false
                    surface.authenticating = false
                    lock.locked            = false
                } else {
                    surface.failed         = true
                    surface.authenticating = false
                    surface.inputText      = ""
                    failShake.restart()
                    failTimer.restart()
                }
            }
        }

        function tryUnlock() {
            if (surface.authenticating) return
            surface.authenticating = true
            surface.failed         = false
            pam.start()
        }

        // Clear error after 3s
        Timer {
            id: failTimer
            interval: 3000
            onTriggered: surface.failed = false
        }

        // ── Content ────────────────────────────────────────────────
        Item {
            anchors.fill: parent

            // Blurred wallpaper background
            Image {
                id: wallBg
                anchors.fill: parent
                source: WallpaperService.currentPath
                    ? "file://" + WallpaperService.currentPath : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                layer.enabled: true
                layer.effect: MultiEffect {
                    source: wallBg
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 64
                }
            }

            // Dark overlay
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)
            }

            // ── Center column: card + media card ───────────────────
            Column {
                anchors.centerIn: parent
                spacing: 12

                // ── Main auth card ─────────────────────────────────
                Rectangle {
                    id: card
                    width: 380
                    height: cardCol.implicitHeight + 48
                    radius: 20
                    color: Qt.rgba(0, 0, 0, 0.55)
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1

                    // Shake animation on failure
                    SequentialAnimation {
                        id: failShake
                        PropertyAnimation { target: card; property: "x"; to: -12; duration: 50 }
                        PropertyAnimation { target: card; property: "x"; to:  12; duration: 50 }
                        PropertyAnimation { target: card; property: "x"; to:  -8; duration: 50 }
                        PropertyAnimation { target: card; property: "x"; to:   8; duration: 50 }
                        PropertyAnimation { target: card; property: "x"; to:   0; duration: 50 }
                    }

                    ColumnLayout {
                        id: cardCol
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 24 }
                        spacing: 20

                        // Avatar
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 88; height: 88; radius: 44
                            color: Qt.rgba(1, 1, 1, 0.1)
                            clip: true

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                source: "file://" + StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.face"
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: avatarImg.status !== Image.Ready
                                text: "󰀄"
                                font.pixelSize: 44
                                font.family: "JetBrainsMono Nerd Font"
                                color: "white"
                            }
                        }

                        // Username
                        Text {
                            id: lockUser
                            Layout.alignment: Qt.AlignHCenter
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Process {
                            id: userProc
                            command: ["bash", "-c", "echo $USER"]
                            stdout: StdioCollector {
                                onStreamFinished: lockUser.text = text.trim()
                            }
                            Component.onCompleted: running = true
                        }

                        // Clock
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            Text {
                                id: lockClock
                                Layout.alignment: Qt.AlignHCenter
                                color: "white"
                                font.pixelSize: 52
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                Timer {
                                    interval: 1000; running: true; repeat: true; triggeredOnStart: true
                                    onTriggered: lockClock.text = Qt.formatTime(new Date(), "hh:mm")
                                }
                            }
                            Text {
                                id: lockDate
                                Layout.alignment: Qt.AlignHCenter
                                color: Qt.rgba(1, 1, 1, 0.7)
                                font.pixelSize: 14
                                font.family: "JetBrainsMono Nerd Font"
                                Timer {
                                    interval: 60000; running: true; repeat: true; triggeredOnStart: true
                                    onTriggered: lockDate.text = Qt.formatDate(new Date(), "dddd, MMMM d")
                                }
                            }
                        }

                        // ── Weather ────────────────────────────────
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8
                            visible: WeatherService.ready

                            Text {
                                text: WeatherService.weatherIcon(WeatherService.weatherCode, WeatherService.isDay)
                                font.pixelSize: 22
                                font.family: "JetBrainsMono Nerd Font"
                                color: Colors.mPrimary
                            }
                            Text {
                                text: WeatherService.temperature + "°C"
                                font.pixelSize: 18
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                color: "white"
                            }
                            Text {
                                text: WeatherService.conditionText(WeatherService.weatherCode)
                                font.pixelSize: 13
                                font.family: "JetBrainsMono Nerd Font"
                                color: Qt.rgba(1, 1, 1, 0.55)
                            }
                        }

                        // Password input
                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: 12
                            color: surface.failed
                                ? Qt.rgba(Colors.mError.r, Colors.mError.g, Colors.mError.b, 0.2)
                                : Qt.rgba(1, 1, 1, 0.1)
                            border.color: surface.failed
                                ? Qt.rgba(Colors.mError.r, Colors.mError.g, Colors.mError.b, 0.6)
                                : pwInput.activeFocus
                                    ? Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.8)
                                    : Qt.rgba(1, 1, 1, 0.2)
                            border.width: 1
                            Behavior on color  { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                                spacing: 10

                                Text {
                                    text: surface.authenticating ? "󰔟" : surface.failed ? "󰌾" : "󰍁"
                                    font.pixelSize: 16
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: surface.failed ? Colors.mError : Qt.rgba(1, 1, 1, 0.6)

                                    RotationAnimation on rotation {
                                        running: surface.authenticating
                                        loops: Animation.Infinite
                                        from: 0; to: 360; duration: 1000
                                    }
                                }

                                TextInput {
                                    id: pwInput
                                    Layout.fillWidth: true
                                    echoMode: TextInput.Password
                                    color: "white"
                                    font.pixelSize: 15
                                    font.family: "JetBrainsMono Nerd Font"
                                    focus: true
                                    enabled: !surface.authenticating
                                    text: surface.inputText
                                    onTextChanged: surface.inputText = text
                                    Keys.onReturnPressed: surface.tryUnlock()
                                    Keys.onEnterPressed:  surface.tryUnlock()

                                    // Placeholder
                                    Text {
                                        visible: pwInput.text.length === 0
                                        text: surface.failed ? "Wrong password" : "Enter password…"
                                        color: surface.failed
                                            ? Qt.rgba(Colors.mError.r, Colors.mError.g, Colors.mError.b, 0.8)
                                            : Qt.rgba(1, 1, 1, 0.4)
                                        font: pwInput.font
                                    }
                                }

                                // Unlock button
                                Rectangle {
                                    width: 32; height: 32; radius: 8
                                    color: unlockMa.containsMouse
                                        ? Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.4)
                                        : Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.2)
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰌑"
                                        font.pixelSize: 16
                                        font.family: "JetBrainsMono Nerd Font"
                                        color: Colors.mPrimary
                                    }
                                    MouseArea {
                                        id: unlockMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: surface.tryUnlock()
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Media card (visible only when something is playing) ─
                Rectangle {
                    id: mediaCard
                    width: 380
                    height: mediaRow.implicitHeight + 20
                    radius: 20
                    color: Qt.rgba(0, 0, 0, 0.55)
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    visible: opacity > 0
                    opacity: surface.hasMedia ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                    RowLayout {
                        id: mediaRow
                        anchors { fill: parent; margins: 10 }
                        spacing: 12

                        // Album art thumbnail
                        Rectangle {
                            width: 52; height: 52
                            radius: 10
                            clip: true
                            color: Qt.rgba(1, 1, 1, 0.08)

                            Image {
                                anchors.fill: parent
                                source: surface.activePlayer?.trackArtUrl ?? ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: !(surface.activePlayer?.trackArtUrl)
                                text: "󰎈"
                                font.pixelSize: 22
                                font.family: "JetBrainsMono Nerd Font"
                                color: Qt.rgba(1, 1, 1, 0.4)
                            }
                        }

                        // Track info + progress
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            ColumnLayout {
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: surface.activePlayer?.trackTitle ?? ""
                                    color: "white"
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: surface.activePlayer?.trackArtist ?? ""
                                    color: Qt.rgba(1, 1, 1, 0.55)
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }

                            // Progress bar
                            Rectangle {
                                Layout.fillWidth: true
                                height: 3
                                radius: 2
                                color: Qt.rgba(1, 1, 1, 0.15)

                                Rectangle {
                                    width: {
                                        let len = surface.activePlayer?.length ?? 0
                                        return len > 0
                                            ? Math.min(parent.width * (surface.mediaPos / len), parent.width)
                                            : 0
                                    }
                                    height: parent.height
                                    radius: parent.radius
                                    color: Colors.mPrimary
                                    Behavior on width { NumberAnimation { duration: 400 } }
                                }
                            }
                        }

                        // Playback controls
                        RowLayout {
                            spacing: 0

                            MediaBtn {
                                text: "󰒮"
                                mediaEnabled: surface.activePlayer?.canGoPrevious ?? false
                                onClicked: surface.activePlayer?.previous()
                            }
                            MediaBtn {
                                text: surface.activePlayer?.isPlaying ? "󰏤" : "󰐊"
                                iconSize: 22
                                onClicked: surface.activePlayer?.togglePlaying()
                            }
                            MediaBtn {
                                text: "󰒭"
                                mediaEnabled: surface.activePlayer?.canGoNext ?? false
                                onClicked: surface.activePlayer?.next()
                            }
                        }
                    }
                }
            }

            // Auto-focus password field on any key
            Keys.onPressed: event => {
                if (!pwInput.activeFocus) pwInput.forceActiveFocus()
            }
            focus: true
        }
    }

    // ── Media button component ─────────────────────────────────────
    component MediaBtn: Rectangle {
        property alias text: lbl.text
        property bool mediaEnabled: true
        property int iconSize: 18
        signal clicked

        implicitWidth: 36; implicitHeight: 36
        radius: 8
        color: ma.containsMouse && mediaEnabled ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            id: lbl
            anchors.centerIn: parent
            font.pixelSize: parent.iconSize
            font.family: "JetBrainsMono Nerd Font"
            color: parent.mediaEnabled ? "white" : Qt.rgba(1, 1, 1, 0.3)
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (parent.mediaEnabled) parent.clicked()
        }
    }
}
