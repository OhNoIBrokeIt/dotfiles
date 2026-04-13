pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // ── Exposed state ──────────────────────────────────────────────
    property real temperature: 0
    property int  weatherCode: -1
    property bool isDay:       true
    property bool ready:       false
    property real lat:         0
    property real lon:         0
    property string locationName: "Automatic"
    property bool hasLocation: false

    // ── WMO code → nerd font glyph ────────────────────────────────
    function weatherIcon(code, day) {
        if (code === 0)           return day ? "󰖙" : "󰖔"
        if (code === 1)           return day ? "󰖕" : "󰼱"
        if (code <= 3)            return "󰖐"
        if (code <= 49)           return "󰖑"
        if (code <= 59)           return "󰖌"
        if (code <= 69)           return "󰖗"
        if (code <= 79)           return "󰼶"
        if (code <= 82)           return "󰖗"
        if (code <= 86)           return "󰼶"
        return "󰖓"
    }

    function conditionText(code) {
        if (code === 0)  return "Clear"
        if (code === 1)  return "Mainly clear"
        if (code === 2)  return "Partly cloudy"
        if (code === 3)  return "Overcast"
        if (code <= 49)  return "Fog"
        if (code <= 59)  return "Drizzle"
        if (code <= 65)  return "Rain"
        if (code <= 69)  return "Freezing rain"
        if (code <= 77)  return "Snow"
        if (code <= 82)  return "Rain showers"
        if (code <= 86)  return "Snow showers"
        return "Thunderstorm"
    }

    function setLocation(name, latitude, longitude) {
        root.locationName = name
        root.lat = parseFloat(latitude)
        root.lon = parseFloat(longitude)
        root.hasLocation = true
        root._fetchWeather()
    }

    // ── Search Geolocation ────────────────────────────────────────
    property var _searchProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let d = JSON.parse(text)
                    if (d.length > 0) {
                        let top = d[0]
                        root.setLocation(top.display_name.split(",")[0], top.lat, top.lon)
                    }
                } catch(e) { console.log("Weather search failed:", e) }
            }
        }
    }

    function searchLocation(query) {
        _searchProc.command = [
            "curl", "-sf", "--max-time", "5",
            "--user-agent", "Quickshell-Weather-Service",
            "https://nominatim.openstreetmap.org/search?format=json&q=" + encodeURIComponent(query)
        ]
        _searchProc.running = true
    }

    // ── IP-based Geolocation (Auto) ───────────────────────────────
    property var _geoProc: Process {
        command: ["curl", "-sf", "--max-time", "5", "https://ipinfo.io/json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let d = JSON.parse(text)
                    if (d.loc && root.locationName === "Automatic") {
                        let parts    = d.loc.split(",")
                        root.lat     = parseFloat(parts[0])
                        root.lon     = parseFloat(parts[1])
                        root.locationName = d.city || "Auto"
                        root.hasLocation = true
                        root._fetchWeather()
                    }
                } catch(e) {}
            }
        }
    }

    // ── Weather fetch ──────────────────────────────────────────────
    property var _weatherProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let d  = JSON.parse(text)
                    let cw = d.current_weather
                    root.temperature = Math.round(cw.temperature)
                    root.weatherCode = cw.weathercode
                    root.isDay       = cw.is_day === 1
                    root.ready       = true
                } catch(e) {}
            }
        }
    }

    function _fetchWeather() {
        if (!root.hasLocation) return
        _weatherProc.command = [
            "curl", "-sf", "--max-time", "10",
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude="       + root.lat
            + "&longitude="      + root.lon
            + "&current_weather=true"
        ]
        _weatherProc.running = true
    }

    property var _boot: Timer {
        interval: 1000
        running: true
        repeat: false
        onTriggered: root._geoProc.running = true
    }

    property var _refresh: Timer {
        interval: 1800000
        running: root.hasLocation
        repeat: true
        onTriggered: root._fetchWeather()
    }
}
