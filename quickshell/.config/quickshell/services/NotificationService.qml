pragma Singleton
import QtQuick

QtObject {
    id: root

    property var notifications: []   // newest first, each entry: { notif, time }
    property int unreadCount:   0

    signal newNotification(var entry)

    function _add(notif) {
        notif.tracked = true
        let entry = { notif: notif, time: new Date() }
        let arr = root.notifications.slice()
        arr.unshift(entry)
        root.notifications = arr
        root.unreadCount   = arr.length
        root.newNotification(entry)
    }

    function dismiss(entry) {
        entry.notif.dismiss()
        root.notifications = root.notifications.filter(e => e !== entry)
        root.unreadCount   = root.notifications.length
    }

    function clearAll() {
        for (let e of root.notifications) e.notif.dismiss()
        root.notifications = []
        root.unreadCount   = 0
    }

    function timeAgo(date) {
        let secs = Math.floor((new Date() - date) / 1000)
        if (secs < 60)  return "just now"
        if (secs < 3600) return Math.floor(secs / 60) + "m ago"
        if (secs < 86400) return Math.floor(secs / 3600) + "h ago"
        return Math.floor(secs / 86400) + "d ago"
    }
}
