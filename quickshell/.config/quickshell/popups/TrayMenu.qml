import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import "../theme"

PopupWindow {
    id: root

    property var trayItem: null
    signal requestClose

    color: "transparent"
    visible: false

    implicitWidth:  menuCol.implicitWidth  + 16
    implicitHeight: menuCol.implicitHeight + 12

    QsMenuOpener {
        id: opener
        menu: root.trayItem ? root.trayItem.menu : null
    }

    function showAt(item) {
        anchor.item       = item
        anchor.gravity    = Edges.Bottom | Edges.Right
        anchor.adjustment = PopupAdjustment.SlideX | PopupAdjustment.SlideY
        visible = true
    }

    // compositor dismissal → notify parent
    onVisibleChanged: if (!visible) requestClose()

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Colors.pillBg()

        Column {
            id: menuCol
            x: 8; y: 6
            spacing: 2

            Repeater {
                model: opener.children ? opener.children.values : []
                delegate: Item {
                    required property var modelData
                    readonly property bool sep: modelData.isSeparator

                    width:  menuCol.width > 0 ? menuCol.width : implicitWidth
                    height: sep ? 9 : 32

                    Rectangle {
                        visible: sep
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 1
                        color: Colors.borderCol()
                    }

                    Rectangle {
                        visible: !sep
                        anchors.fill: parent
                        radius: 8
                        color: itemMouse.containsMouse && modelData.enabled
                               ? Colors.hoverBg() : "transparent"

                        RowLayout {
                            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                            spacing: 8

                            Text {
                                text: modelData.text ?? ""
                                color: modelData.enabled ? Colors.mOnSurface : Colors.mOutline
                                font.pixelSize: 13
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: modelData.enabled && !sep
                            onClicked: {
                                modelData.triggered()
                                root.visible = false
                            }
                        }
                    }
                }
            }
        }
    }
}
