import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "components"

Scope {
    PanelWindow {
        id: window
        
        property string rawAccent: "#89b4fa"
        property bool isWallpaperLight: false
        
        property color themeAccent: isWallpaperLight ? Qt.lighter(rawAccent, 1.4) : Qt.darker(rawAccent, 1.2)
        
        focusable: window.isExpanded
        
        screen: {
            for (var i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === (Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "")) {
                    return Quickshell.screens[i];
                }
            }
            return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
        }
        
        anchors.top: true
        anchors.left: true
        anchors.right: true
        
        implicitHeight: islandRow.height + (settingsIsland.layoutStyle === 1 ? 12 : 24)

        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore 

        color: "transparent"

        property bool isExpanded: dynamicIsland.activeMode !== "compact" || musicIsland.expanded || settingsIsland.expanded

        mask: Region { 
            item: window.isExpanded ? mainContainer : islandRow 
        }

        Item {
            id: mainContainer
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                z: 0
                enabled: window.isExpanded
                onClicked: {
                    musicIsland.expanded = false;
                    settingsIsland.expanded = false;
                    collapseProc.running = false;
                    collapseProc.running = true;
                }
            }

            Row {
                id: islandRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                
                anchors.topMargin: settingsIsland.layoutStyle === 1 ? -4 : 8
                
                spacing: 10
                z: 1

                MusicIsland { 
                    id: musicIsland 
                    appearanceMode: settingsIsland.appearanceMode 
                    layoutStyle: settingsIsland.layoutStyle 
                    themeAccent: settingsIsland.appearanceMode === 2 ? "#e2e8f0" : window.themeAccent
                    isWallpaperLight: window.isWallpaperLight
                }
                
                DynamicIsland { 
                    id: dynamicIsland 
                    appearanceMode: settingsIsland.appearanceMode 
                    layoutStyle: settingsIsland.layoutStyle 
                    themeAccent: settingsIsland.appearanceMode === 2 ? "#e2e8f0" : window.themeAccent
                    isWallpaperLight: window.isWallpaperLight
                }
                
                SettingsIsland { 
                    id: settingsIsland 
                    themeAccent: settingsIsland.appearanceMode === 2 ? "#e2e8f0" : window.themeAccent
                    isWallpaperLight: window.isWallpaperLight
                }
            }
        }

        HyprlandFocusGrab {
            id: focusGrab
            active: window.isExpanded && window.visible
            windows: [ window ]
            onCleared: {
                musicIsland.expanded = false;
                settingsIsland.expanded = false;
                collapseProc.running = false;
                collapseProc.running = true;
            }
        }

        Process {
            id: colorFetchProc
            command: ["bash", "-c", "cat ~/.config/quickshell/island_colors 2>/dev/null || echo '#1e1e2e|#89b4fa'"]
            stdout: StdioCollector {
                onStreamFinished: {
                    var data = this.text.trim().split("|");
                    if (data.length >= 2) {
                        var hex = data[0].replace("#", "");
                        if (hex.length === 6) {
                            var r = parseInt(hex.substr(0, 2), 16);
                            var g = parseInt(hex.substr(2, 2), 16);
                            var b = parseInt(hex.substr(4, 2), 16);
                            var luminance = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
                            window.isWallpaperLight = (luminance > 128);
                        }
                        window.rawAccent = data[1];
                    }
                }
            }
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                colorFetchProc.running = false;
                colorFetchProc.running = true;
            }
        }

        Timer {
            interval: 500
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                musicPollProc.running = false
                musicPollProc.running = true
            }
        }

        Process {
            id: musicPollProc
            command: ["bash", "-c", "bash ~/.config/quickshell/music-status.sh"]
            onExited: {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", "file:///tmp/island_music?t=" + new Date().getTime());
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        var data = xhr.responseText ? xhr.responseText.trim().split("|") : [];
                        if (data.length >= 5) {
                            musicIsland.isPlaying = (data[0] === "true");
                            musicIsland.trackTitle = data[1];
                            musicIsland.artistName = data[2];
                            musicIsland.albumArt = data[3];
                            musicIsland.progressValue = parseFloat(data[4]) || 0.0;
                        }
                    }
                }
                xhr.send();
            }
        }

        Process {
            id: collapseProc
            command: ["bash", "-c", "echo 'compact' > /tmp/island_mode"]
        }
    }
}