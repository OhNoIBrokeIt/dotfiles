import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"
import "../services"

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    // Sit behind everything, take full screen, reserve no zone
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusiveZone: -1
    anchors { top: true; bottom: true; left: true; right: true }
    color: "black"

    // ── Monitor identity ───────────────────────────────────────────
    readonly property bool isOled: modelData.name === "DP-2"
    readonly property string wallpaperDir: isOled
        ? "/home/ohnoibrokeit/Pictures/Wallpapers/ultrawide"
        : "/home/ohnoibrokeit/Pictures/Wallpapers/4k"

    // ── State ──────────────────────────────────────────────────────
    property var   files:     []
    property int   lastIndex: -1
    property bool  useA:      true

    property int transitionType: 0

    // ── Respond to manual rotate request ──────────────────────────
    Connections {
        target: WallpaperService
        function onRotateRequested() { root.rotate() }
    }

    // ── Image layer A ──────────────────────────────────────────────
    Image {
        id: imgA
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: 1.0
        Behavior on opacity { NumberAnimation { duration: 1800; easing.type: Easing.InOutCubic } }
        Behavior on x       { NumberAnimation { duration: 1800; easing.type: Easing.InOutCubic } }
    }

    // ── Image layer B ──────────────────────────────────────────────
    Image {
        id: imgB
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: 0.0
        Behavior on opacity { NumberAnimation { duration: 1800; easing.type: Easing.InOutCubic } }
        Behavior on x       { NumberAnimation { duration: 1800; easing.type: Easing.InOutCubic } }
        Behavior on scale   { NumberAnimation { duration: 1800; easing.type: Easing.InOutCubic } }
    }

    // ── Matugen — OLED monitor only, drives Colors.qml live ───────
    Process {
        id: matugenProc
    }

    // ── Directory scan ─────────────────────────────────────────────
    Process {
        id: scanner
        command: ["bash", "-c", `ls -1 "${root.wallpaperDir}"`]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n").filter(
                    f => /\.(jpg|jpeg|png|webp|gif)$/i.test(f)
                )
                root.files = lines
                if (lines.length > 0) root.rotate()
            }
        }
    }

    // ── Rotation timer — driven by WallpaperService.intervalMs ────
    Timer {
        interval: WallpaperService.intervalMs > 0 ? WallpaperService.intervalMs : 1
        running: root.files.length > 0 && WallpaperService.intervalMs > 0
        repeat: true
        onTriggered: root.rotate()
    }

    // ── Transition function ────────────────────────────────────────
    function rotate() {
        if (files.length === 0) return

        // Pick a random index, avoid repeating the same image
        let idx
        do { idx = Math.floor(Math.random() * files.length) }
        while (idx === lastIndex && files.length > 1)
        lastIndex = idx

        const src = "file://" + wallpaperDir + "/" + files[idx]
        transitionType = WallpaperService.transition >= 0
            ? WallpaperService.transition
            : Math.floor(Math.random() * 3)

        // Publish current path for the control center thumbnail
        if (isOled)
            WallpaperService.currentPath = wallpaperDir + "/" + files[idx]
        else
            WallpaperService.currentPath4k = wallpaperDir + "/" + files[idx]

        // Determine which image layer is coming in
        let incoming = useA ? imgA : imgB
        let outgoing = useA ? imgB : imgA

        // Reset incoming position/scale before loading
        incoming.x = (transitionType === 2) ? root.width : 0
        if (transitionType === 1) {
            incoming.scale = 1.06
        } else {
            incoming.scale = 1.0
        }
        incoming.opacity = 0.0
        incoming.source = src

        // Animate in
        incoming.opacity = 1.0
        incoming.x = 0
        if (transitionType === 1) incoming.scale = 1.0

        // Animate out
        outgoing.opacity = 0.0
        if (transitionType === 2) outgoing.x = -root.width

        useA = !useA

        // Run matugen on the OLED wallpaper to regenerate the color scheme
        if (isOled) {
            matugenProc.command = [
                "matugen", "--quiet", "--prefer=saturation", "--source-color-index", "0",
                "image", wallpaperDir + "/" + files[idx]
            ]
            matugenProc.running = true
        }
    }

    Component.onCompleted: scanner.running = true
}
