//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import "bar"
import "wallpaper"
import "lockscreen"
import "popups"
import "services"

ShellRoot {
    PwObjectTracker {
        objects: Pipewire.nodes
    }

    NotificationServer {
        id: notificationServer
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true
        onNotification: notif => NotificationService._add(notif)
    }

    LockScreen {
        id: lockScreen
    }

    IpcHandler {
        target: "lock"
        function lock() { lockScreen.locked = true }
    }

    Variants {
        model: Quickshell.screens
        delegate: Wallpaper {}
    }

    Variants {
        model: Quickshell.screens
        delegate: NotificationToast {
            modelData: modelData
            active: Quickshell.screens.indexOf(modelData) === 0
        }
    }

    BarScreen {}
}
