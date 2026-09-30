import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: clipboardRoot
    implicitWidth: parent ? parent.width : 450
    height: 380

    property string themeAccent: "#89b4fa"
    property int appearanceMode: 0 
    property bool isWallpaperLight: false
    
    property string _lastClipboardHash: ""

    property color glassBgColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05)
    property color glassBorderColor: isWallpaperLight ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.15)
    property color glassInnerBg: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(0, 0, 0, 0.15)
    property color glassHoverColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.1)
    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassSubTextColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(1, 1, 1, 0.7)

    property color cardBgColor: appearanceMode === 0 ? "#181825" : (appearanceMode === 1 ? "#e8e8ed" : glassBgColor)
    property color cardBorderColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassBorderColor)
    property color innerBgColor: appearanceMode === 0 ? "#1a1b26" : (appearanceMode === 1 ? "#ffffff" : glassInnerBg)
    property color innerHoverColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassHoverColor)
    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color subTextColor: appearanceMode === 0 ? "#6c7086" : (appearanceMode === 1 ? "#86868b" : glassSubTextColor)

    Process {
        id: clipDaemon
        command: ["bash", "-c", "pgrep -f 'wl-paste --type text' > /dev/null || (wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store &)"]
        running: true
    }

    component DarkFrostOverlay: Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        visible: clipboardRoot.appearanceMode === 2
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
            GradientStop { position: 0.7; color: clipboardRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 1.0; color: clipboardRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
        }
        
        border.color: clipboardRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: clipboardRoot.isWallpaperLight ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
        }
    }

    Rectangle {
        anchors.fill: parent
        color: clipboardRoot.cardBgColor
        radius: 16
        border.color: clipboardRoot.cardBorderColor
        border.width: 1
        clip: true

        DarkFrostOverlay {}

        Text {
            id: headerTitle
            text: "CLIPBOARD HISTORY"
            color: clipboardRoot.subTextColor
            font.family: "Inter"
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1.2
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 16
        }

        ListView {
            id: clipList
            anchors.top: headerTitle.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            anchors.topMargin: 10
            spacing: 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            
            model: ListModel { id: clipModel }

            delegate: Rectangle {
                id: delegateRect
                width: clipList ? clipList.width : parent.width
                height: isImg ? 64 : 48
                color: clipboardRoot.appearanceMode === 2 ? "transparent" : (itemMouse.containsMouse ? clipboardRoot.innerHoverColor : clipboardRoot.innerBgColor)
                radius: 10
                border.color: clipboardRoot.appearanceMode === 2 ? "transparent" : clipboardRoot.cardBorderColor
                border.width: clipboardRoot.appearanceMode === 2 ? 0 : 1
                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutExpo } }

                DarkFrostOverlay {}

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.color: clipboardRoot.themeAccent
                    border.width: 1
                    visible: clipboardRoot.appearanceMode === 2 && itemMouse.containsMouse
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Rectangle {
                        width: isImg ? 50 : 28
                        height: isImg ? 44 : 28
                        radius: 6
                        color: clipboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.05) : clipboardRoot.cardBgColor
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: !isImg
                            text: "󰅍"
                            color: clipboardRoot.themeAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            Behavior on color { ColorAnimation { duration: 400 } }
                        }

                        Image {
                            anchors.fill: parent
                            visible: isImg
                            source: isImg ? "file:///tmp/qh_clips/" + clipId + ".png" : ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: content
                        color: clipboardRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.bold: isImg
                        elide: Text.ElideRight
                        width: parent.width - (isImg ? 84 : 62)
                        maximumLineCount: isImg ? 1 : 2
                        wrapMode: isImg ? Text.NoWrap : Text.Wrap
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pasteProc.command = ["bash", "-c", "cliphist list | grep '^" + clipId + "\\b' | cliphist decode | wl-copy"];
                        pasteProc.running = false;
                        pasteProc.running = true;
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: clipModel.count === 0
            text: "Clipboard is empty"
            color: clipboardRoot.subTextColor
            font.family: "Inter"
            font.pixelSize: 13
        }
    }

    Process {
        id: fetchProc
        command: ["bash", "-c", "cliphist list | head -n 10"]
        stdout: StdioCollector {
            onStreamFinished: {
                var newOutput = this.text ? this.text.trim() : "";
                if (newOutput === clipboardRoot._lastClipboardHash) return;
                clipboardRoot._lastClipboardHash = newOutput;

                clipModel.clear();
                var lines = newOutput.split("\n");
                var triggerImgDecode = false;

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i];
                    if (!line || line.trim() === "") continue;

                    var firstTab = line.indexOf("\t");
                    if (firstTab > -1) {
                        var id = line.substring(0, firstTab);
                        var rawContent = line.substring(firstTab + 1);
                        
                        var isImage = rawContent.indexOf("[[ binary data") !== -1;
                        if (isImage) {
                            triggerImgDecode = true;
                            clipModel.append({
                                "clipId": id,
                                "content": "Image Copied",
                                "isImg": true
                            });
                        } else {
                            clipModel.append({
                                "clipId": id,
                                "content": rawContent,
                                "isImg": false
                            });
                        }
                    }
                }

                if (triggerImgDecode) {
                    imgDecodeProc.running = false;
                    imgDecodeProc.running = true;
                }
            }
        }
    }

    Process {
        id: imgDecodeProc
        command: ["bash", "-c", "mkdir -p /tmp/qh_clips && cliphist list | head -n 10 | grep '\\[\\[ binary data' | while read -r line; do id=$(echo \"$line\" | cut -f1); if [ ! -f \"/tmp/qh_clips/$id.png\" ]; then echo \"$line\" | cliphist decode > \"/tmp/qh_clips/$id.png\" 2>/dev/null; fi; done"]
    }

    Process { id: pasteProc }

    Timer {
        id: initTimer
        interval: 150
        running: clipboardRoot.visible
        repeat: false
        onTriggered: {
            fetchProc.running = false;
            fetchProc.running = true;
        }
    }

    Timer {
        interval: 1000
        running: clipboardRoot.visible
        repeat: true
        onTriggered: {
            fetchProc.running = false;
            fetchProc.running = true;
        }
    }
}