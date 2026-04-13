pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    // Pick a meaningful player only:
    // 1) first playing player with a real title
    // 2) otherwise first paused player with a real title
    // 3) otherwise null
    readonly property var activePlayer: {
        const vals = Mpris.players.values
        let paused = null
        for (let i = 0; i < vals.length; ++i) {
            const p = vals[i]
            if (!p || !p.trackTitle || String(p.trackTitle).trim() === "")
                continue
            if (p.isPlaying)
                return p
            if (paused === null)
                paused = p
        }
        return paused
    }

    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: hasPlayer ? activePlayer.isPlaying : false

    readonly property string title:
        hasPlayer ? (activePlayer.trackTitle || "Nothing playing") : "Nothing playing"

    readonly property string artist:
        hasPlayer ? (activePlayer.trackArtist || "") : ""

    readonly property string artUrl:
        hasPlayer ? (activePlayer.trackArtUrl || "") : ""

    readonly property real length:
        hasPlayer ? (activePlayer.length || 0) : 0

    readonly property bool canPlayPause:
        hasPlayer

    readonly property bool canGoPrevious:
        hasPlayer ? !!activePlayer.canGoPrevious : false

    readonly property bool canGoNext:
        hasPlayer ? !!activePlayer.canGoNext : false

    readonly property bool canSeek:
        hasPlayer ? !!activePlayer.canSeek : false

    function togglePlaying() {
        if (hasPlayer) activePlayer.togglePlaying()
    }

    function previous() {
        if (hasPlayer && canGoPrevious) activePlayer.previous()
    }

    function next() {
        if (hasPlayer && canGoNext) activePlayer.next()
    }

    function seek(pos) {
        if (hasPlayer && canSeek) activePlayer.seek(pos)
    }
}
