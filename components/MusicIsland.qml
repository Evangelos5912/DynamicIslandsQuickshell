import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: musicRoot

    property int layoutStyle: 0
    property int appearanceMode: 0
    property string themeAccent: "#89b4fa"
    property bool isWallpaperLight: false
    
    property bool isPlaying: false
    property string trackTitle: "No Music"
    property string artistName: "Paused"
    property string albumArt: ""
    property real progressValue: 0.0
    property bool ignorePoll: false 

    property bool expanded: false
    property string activeMode: expanded ? "expanded" : "compact"
    
    property color glassBgColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.08)
    property color glassBtnColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.05) : "transparent"
    property color glassBtnHoverColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.1)
    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassSubTextColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(1, 1, 1, 0.6)
    property color glassTrackColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(0, 0, 0, 0.3)
    property color glassBorderOuter: isWallpaperLight ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.15)
    property color glassBorderInner: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.3)

    property color bgColor: appearanceMode === 0 ? "#1a1b26" : (appearanceMode === 1 ? "#f5f5f7" : glassBgColor)
    property color btnColor: appearanceMode === 0 ? "#181825" : (appearanceMode === 1 ? "#e8e8ed" : glassBtnColor)
    property color btnHoverColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassBtnHoverColor)
    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color subTextColor: appearanceMode === 0 ? "#6c7086" : (appearanceMode === 1 ? "#86868b" : glassSubTextColor)
    property color trackColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#e8e8ed" : glassTrackColor)

    Timer {
        id: bounceShieldTimer
        interval: 1500
        repeat: false
        onTriggered: musicRoot.ignorePoll = false
    }

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: {
            musicPollProc.running = false;
            musicPollProc.running = true;
        }
    }

    implicitWidth: activeMode === "compact" ? 42 : 380
    implicitHeight: activeMode === "compact" ? 36 : 120
    width: implicitWidth
    height: implicitHeight

    topLeftRadius: layoutStyle === 1 ? 0 : (activeMode === "compact" ? 18 : 26)
    topRightRadius: layoutStyle === 1 ? 0 : (activeMode === "compact" ? 18 : 26)
    bottomLeftRadius: activeMode === "compact" ? 18 : 26
    bottomRightRadius: activeMode === "compact" ? 18 : 26

    color: musicRoot.bgColor
    border.color: musicRoot.appearanceMode === 2 ? "transparent" : musicRoot.themeAccent
    border.width: 1
    clip: true

    Behavior on implicitWidth { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on implicitHeight { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on color { ColorAnimation { duration: 400 } }
    Behavior on border.color { ColorAnimation { duration: 400 } }

    Item {
        anchors.fill: parent
        visible: musicRoot.appearanceMode === 2
        
        Rectangle {
            anchors.fill: parent
            topLeftRadius: musicRoot.topLeftRadius
            topRightRadius: musicRoot.topRightRadius
            bottomLeftRadius: musicRoot.bottomLeftRadius
            bottomRightRadius: musicRoot.bottomRightRadius
            color: "transparent"
            border.color: musicRoot.glassBorderOuter
            border.width: 1
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1 
            topLeftRadius: musicRoot.topLeftRadius > 0 ? musicRoot.topLeftRadius - 1 : 0
            topRightRadius: musicRoot.topRightRadius > 0 ? musicRoot.topRightRadius - 1 : 0
            bottomLeftRadius: musicRoot.bottomLeftRadius - 1
            bottomRightRadius: musicRoot.bottomRightRadius - 1
            color: "transparent"
            border.color: musicRoot.glassBorderInner
            border.width: 1
        }
    }

    Item {
        anchors.fill: parent
        opacity: musicRoot.activeMode === "compact" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Row {
            anchors.centerIn: parent
            spacing: 3
            visible: musicRoot.isPlaying

            Rectangle {
                id: bar1
                width: 3; height: 6; radius: 1.5
                color: musicRoot.themeAccent
                SequentialAnimation {
                    running: musicRoot.isPlaying && musicRoot.activeMode === "compact"
                    loops: Animation.Infinite
                    NumberAnimation { target: bar1; property: "height"; to: 14; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { target: bar1; property: "height"; to: 6; duration: 700; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                id: bar2
                width: 3; height: 12; radius: 1.5
                color: musicRoot.themeAccent
                SequentialAnimation {
                    running: musicRoot.isPlaying && musicRoot.activeMode === "compact"
                    loops: Animation.Infinite
                    NumberAnimation { target: bar2; property: "height"; to: 4; duration: 600; easing.type: Easing.InOutSine }
                    NumberAnimation { target: bar2; property: "height"; to: 12; duration: 600; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                id: bar3
                width: 3; height: 8; radius: 1.5
                color: musicRoot.themeAccent
                SequentialAnimation {
                    running: musicRoot.isPlaying && musicRoot.activeMode === "compact"
                    loops: Animation.Infinite
                    NumberAnimation { target: bar3; property: "height"; to: 16; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { target: bar3; property: "height"; to: 8; duration: 800; easing.type: Easing.InOutSine }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "󰝛"
            color: musicRoot.themeAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            visible: !musicRoot.isPlaying
        }
    }

    Item {
        anchors.fill: parent
        opacity: musicRoot.activeMode === "expanded" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        Item {
            anchors.fill: parent
            anchors.margins: 14

            Row {
                id: contentRow
                width: parent.width
                height: 56
                spacing: 14
                anchors.top: parent.top

                Rectangle {
                    width: 56
                    height: 56
                    radius: 12
                    color: musicRoot.appearanceMode === 2 ? "transparent" : "#181825"
                    border.color: musicRoot.appearanceMode === 2 ? "transparent" : "#313244"
                    border.width: 1
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.fill: parent
                        source: musicRoot.albumArt.startsWith("file://") || musicRoot.albumArt.startsWith("http") ? musicRoot.albumArt : (musicRoot.albumArt !== "" ? "file://" + musicRoot.albumArt : "")
                        fillMode: Image.PreserveAspectCrop
                        visible: musicRoot.albumArt !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰝚"
                        color: musicRoot.themeAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 24
                        visible: musicRoot.albumArt === ""
                    }
                }

                Column {
                    width: 220
                    height: parent.height
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: musicRoot.trackTitle
                        color: musicRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: musicRoot.artistName
                        color: musicRoot.subTextColor
                        font.family: "Inter"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Row {
                        spacing: 10
                        
                        MediaButton {
                            icon: "󰒮"
                            onClick: musicPrevProc.running = true
                        }
                        MediaButton {
                            icon: musicRoot.isPlaying ? "󰏤" : "󰐊"
                            onClick: {
                                musicRoot.isPlaying = !musicRoot.isPlaying;
                                musicToggleProc.running = true;
                                musicRoot.ignorePoll = true;
                                bounceShieldTimer.restart();
                            }
                        }
                        MediaButton {
                            icon: "󰒭"
                            onClick: musicNextProc.running = true
                        }
                    }
                }

                Row {
                    width: 44
                    height: 40
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: 4
                        Rectangle {
                            id: cavaBar
                            width: 6
                            radius: 3
                            color: musicRoot.themeAccent
                            height: musicRoot.isPlaying ? Math.floor(Math.random() * 32) + 8 : 4
                            anchors.bottom: parent.bottom

                            Timer {
                                interval: 100
                                running: musicRoot.isPlaying && musicRoot.activeMode === "expanded"
                                repeat: true
                                onTriggered: {
                                    cavaBar.height = Math.floor(Math.random() * 32) + 8;
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 5
                radius: 2.5
                color: musicRoot.trackColor
                border.color: musicRoot.appearanceMode === 2 ? musicRoot.glassBorderInner : "transparent"
                border.width: musicRoot.appearanceMode === 2 ? 1 : 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2

                Rectangle {
                    width: parent.width * Math.max(0.0, Math.min(1.0, musicRoot.progressValue))
                    height: parent.height
                    radius: parent.radius
                    color: musicRoot.themeAccent
                    Behavior on width { NumberAnimation { duration: 100 } }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            mouse.accepted = true;
            musicRoot.expanded = !musicRoot.expanded;
        }
    }

    component MediaButton: Rectangle {
        property string icon: ""
        signal click()

        width: 30
        height: 30
        radius: 15
        color: btnMouse.containsMouse ? musicRoot.btnHoverColor : musicRoot.btnColor
        border.color: musicRoot.appearanceMode === 2 ? "transparent" : (btnMouse.containsMouse ? musicRoot.themeAccent : "transparent")
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        Text {
            anchors.centerIn: parent
            text: icon
            color: musicRoot.themeAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: (mouse) => { mouse.accepted = true; }
            onClicked: (mouse) => {
                mouse.accepted = true;
                parent.click();
            }
        }
    }

    Process {
        id: musicPollProc
        command: [
            "bash",
            "-c",
            "P=$(playerctl --list-all 2>/dev/null | grep -E 'firefox|chromium|spotify|mpv' | head -n 1); if [ -z \"$P\" ]; then P=$(playerctl --list-all 2>/dev/null | head -n 1); fi; if [ -z \"$P\" ]; then echo 'None'; exit 0; fi; S=$(playerctl -p \"$P\" status 2>/dev/null); T=$(playerctl -p \"$P\" metadata title 2>/dev/null); A=$(playerctl -p \"$P\" metadata artist 2>/dev/null); U=$(playerctl -p \"$P\" metadata mpris:artUrl 2>/dev/null); POS=$(playerctl -p \"$P\" position 2>/dev/null || echo '0'); LEN=$(playerctl -p \"$P\" metadata mpris:length 2>/dev/null || echo '1'); echo \"$S~~$T~~$A~~$U~~$POS~~$LEN\""
        ]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim();
                if (out === "" || out === "None") {
                    if (!musicRoot.ignorePoll) musicRoot.isPlaying = false;
                    musicRoot.trackTitle = "No Music";
                    musicRoot.artistName = "Paused";
                    musicRoot.albumArt = "";
                    musicRoot.progressValue = 0.0;
                    return;
                }

                var data = out.split("~~");
                if (data.length >= 1 && !musicRoot.ignorePoll) {
                    musicRoot.isPlaying = (data[0] === "Playing");
                }
                
                musicRoot.trackTitle = (data.length >= 2 && data[1] !== "") ? data[1] : "Unknown Title";
                musicRoot.artistName = (data.length >= 3 && data[2] !== "") ? data[2] : "Unknown Artist";
                musicRoot.albumArt = (data.length >= 4 && data[3] !== "") ? data[3] : "";
                
                var pos = (data.length >= 5 && data[4] !== "") ? parseFloat(data[4]) : 0;
                var len = (data.length >= 6 && data[5] !== "") ? parseFloat(data[5]) : 0;
                
                musicRoot.progressValue = (len > 0) ? ((pos * 1000000) / len) : 0.0;
            }
        }
    }

    Process { id: musicPrevProc; command: ["playerctl", "previous"] }
    Process { id: musicToggleProc; command: ["playerctl", "play-pause"] }
    Process { id: musicNextProc; command: ["playerctl", "next"] }
}