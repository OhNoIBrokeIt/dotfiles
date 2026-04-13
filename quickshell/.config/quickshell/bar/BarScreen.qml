import Quickshell
import Quickshell.Wayland
import QtQuick
import "../popups"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            screen: modelData
            color: "transparent"
            visible: true

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: 42

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 42

            TopBar {
                id: bar
                anchors.fill: parent
                modelData: panel.modelData
                barScreen: panel
            }

            Loader {
                id: launcherLoader
                active: true
                sourceComponent: Launcher {
                    modelData: panel.modelData
                    isOpen: bar.launcherOpen
                    onRequestClose: bar.launcherOpen = false
                }
            }

            Loader {
                id: weatherLoader
                active: true
                sourceComponent: WeatherPopup {
                    modelData: panel.modelData
                    isOpen: bar.weatherOpen
                    pillCenterX: bar.weatherPillCenterX
                    onRequestClose: bar.weatherOpen = false
                }
            }

            Loader {
                id: mediaLoader
                active: true
                sourceComponent: MediaPopup {
                    modelData: panel.modelData
                    isOpen: bar.mediaOpen
                    pillCenterX: bar.mediaPillCenterX
                    onRequestClose: bar.mediaOpen = false
                }
            }

            Loader {
                id: volumeLoader
                active: true
                sourceComponent: VolumePopup {
                    modelData: panel.modelData
                    isOpen: bar.volumeOpen
                    pillCenterX: bar.volumePillCenterX
                    onRequestClose: bar.volumeOpen = false
                }
            }

            Loader {
                id: sysmonLoader
                active: true
                sourceComponent: SysmonPopup {
                    modelData: panel.modelData
                    isOpen: bar.sysmonOpen
                    pillCenterX: bar.sysmonPillCenterX

                    cpu: bar.sysCpu
                    cpuTemp: bar.sysCpuTemp
                    gpu: bar.sysGpu
                    gpuTemp: bar.sysGpuTemp
                    gpuMemUsed: bar.sysGpuMemUsed
                    gpuMemTotal: bar.sysGpuMemTotal
                    ramPct: bar.sysRamPct
                    ramUsed: bar.sysRamUsed
                    ramTotal: bar.sysRamTotal

                    onRequestClose: bar.sysmonOpen = false
                }
            }

            Loader {
                id: notifLoader
                active: true
                sourceComponent: NotificationCenter {
                    modelData: panel.modelData
                    isOpen: bar.notifOpen
                    pillCenterX: bar.notifPillCenterX
                    onRequestClose: bar.notifOpen = false
                }
            }

            Loader {
                id: ccLoader
                active: true
                sourceComponent: ControlCenter {
                    modelData: panel.modelData
                    isOpen: bar.ccOpen
                    pillCenterX: bar.rightPillCenterX
                    onRequestClose: bar.ccOpen = false
                }
            }
        }
    }
}
