pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var sinkNode: Pipewire.defaultAudioSink
    readonly property var sourceNode: Pipewire.defaultAudioSource

    property var _tracker: PwObjectTracker {
        objects: [root.sinkNode, root.sourceNode]
    }

    readonly property bool sinkReady: Pipewire.ready && sinkNode !== null && sinkNode.audio !== null
    readonly property bool sourceReady: Pipewire.ready && sourceNode !== null && sourceNode.audio !== null

    // Native PipeWire controls
    readonly property real volume: sinkReady ? sinkNode.audio.volume : 0.0
    readonly property bool muted: sinkReady ? sinkNode.audio.muted : false

    readonly property real micVolume: sourceReady ? sourceNode.audio.volume : 0.0
    readonly property bool micMuted: sourceReady ? sourceNode.audio.muted : false

    readonly property string deviceName:
        !sinkNode ? "No output"
                  : (sinkNode.description || sinkNode.nickname || sinkNode.name || "Output")

    readonly property string micName:
        !sourceNode ? "No input"
                    : (sourceNode.description || sourceNode.nickname || sourceNode.name || "Input")

    // Metadata from your helper script for exact displayed format/rate
    property string sampleRate: ""
    property string sampleFormat: ""
    property string displayDevice: ""

    function startMetaPoll() {
        if (!metaProc.running)
            metaProc.running = true
    }

    property var metaProc: Process {
        command: ["bash", "-lc", "/home/ohnoibrokeit/.config/hypr/scripts/pw-audioinfo.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim())
                    root.sampleRate = data.rate ? String(data.rate) : ""
                    root.sampleFormat = data.format ?? ""
                    root.displayDevice = data.device ?? ""
                } catch (e) {
                    root.sampleRate = ""
                    root.sampleFormat = ""
                    root.displayDevice = ""
                    console.log("AudioService metadata parse failed:", e)
                }
            }
        }
    }

    property var _metaTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.startMetaPoll()
    }

    function setVolume(v) {
        if (!sinkReady) return
        sinkNode.audio.volume = Math.max(0, Math.min(1.5, v))
    }

    function toggleMute() {
        if (!sinkReady) return
        sinkNode.audio.muted = !sinkNode.audio.muted
    }

    function setMicVolume(v) {
        if (!sourceReady) return
        sourceNode.audio.volume = Math.max(0, Math.min(1.0, v))
    }

    function toggleMicMute() {
        if (!sourceReady) return
        sourceNode.audio.muted = !sourceNode.audio.muted
    }
}
