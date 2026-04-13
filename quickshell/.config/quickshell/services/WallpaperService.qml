pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // ── Settings ───────────────────────────────────────────────────
    // intervalMs: 0 = disabled
    property int     intervalMs:  30 * 60 * 1000
    property int     transition:  -1              // -1 = random, 0/1/2 = fixed
    property string  currentPath: ""              // absolute path of current wallpaper (ultrawide)
    property string  currentPath4k: ""            // absolute path of current wallpaper (4k)

    // ── Manual rotate trigger ──────────────────────────────────────
    signal rotateRequested
    function requestRotate() { root.rotateRequested() }
}
