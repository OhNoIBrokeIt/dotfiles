pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // Matugen-generated colors are written here
    property string colorFilePath: "/tmp/qs_colors.json"

    // Default fallback values
    property color mPrimary:          "#ff8a65"
    property color mOnPrimary:        "#2a1208"
    property color mSecondary:        "#ffb74d"
    property color mOnSecondary:      "#2b1900"
    property color mTertiary:         "#81c784"
    property color mOnTertiary:       "#0c2410"
    property color mError:            "#ef5350"
    property color mOnError:          "#2b0b0a"
    property color mSurface:          "#101416"
    property color mOnSurface:        "#e0e3e5"
    property color mSurfaceVariant:   "#1c2022"
    property color mOnSurfaceVariant: "#bfc8ce"
    property color mOutline:          "#3f484d"
    property color mShadow:           "#000000"
    property color mHover:            "#2a2f33"
    property color mOnHover:          "#e0e3e5"

    // Dynamic loader using Process since FileReader is not available
    property var _loader: Process {
        id: colorLoader
        command: ["cat", root.colorFilePath]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return
                try {
                    const data = JSON.parse(text)
                    for (let key in data) {
                        if (root.hasOwnProperty(key)) {
                            root[key] = data[key]
                        }
                    }
                } catch (e) {
                    console.log("Colors.qml: Failed to parse theme JSON:", e)
                }
            }
        }
    }

    // Refresh every few seconds or triggered manually
    property var _timer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: colorLoader.running = true
    }

    // ── Helper Functions ──────────────────────────────────────────
    function pillBg(alpha) {
        return Qt.rgba(mSurface.r, mSurface.g, mSurface.b, alpha === undefined ? 0.75 : alpha)
    }

    function hoverBg(alpha) {
        return Qt.rgba(mSurfaceVariant.r, mSurfaceVariant.g, mSurfaceVariant.b, alpha === undefined ? 0.90 : alpha)
    }

    function borderCol() {
        return Qt.rgba(mOutline.r, mOutline.g, mOutline.b, 0.4)
    }
}
