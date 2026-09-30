import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Io

Item {
    id: root
    property string themeAccent: "#89b4fa"
    property string wallpaperDir: ""

    signal interacted()
    signal wallpaperSelected(string path) 
    
    Process {
        id: fetchVarProc
        command: ["bash", "-c", "source ~/.config/quickshell/components/Scripts/variables 2>/dev/null; echo \"${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var dir = this.text.trim();
                if (dir !== "") {
                    root.wallpaperDir = "file://" + dir;
                }
            }
        }
    }

    Process {
        id: setWallProcess
    }

    FolderListModel {
        id: folderModel
        folder: root.wallpaperDir
        nameFilters: ["*.jpg", "*.png", "*.jpeg"]
        showDirs: false
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text { 
            text: "󰸉  Wallpaper Carousel"
            color: root.themeAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
        }

        ListView {
            width: parent.width
            height: parent.height - 40
            orientation: ListView.Horizontal
            spacing: 15
            clip: true
            snapMode: ListView.SnapToItem
            
            model: root.wallpaperDir !== "" && root.opacity > 0.8 ? folderModel : null

            delegate: Rectangle {
                width: 320
                height: 180
                radius: 12
                color: "transparent"
                clip: true
                
                Image {
                    anchors.fill: parent
                    source: model.fileUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.interacted();
                        root.wallpaperSelected(model.filePath);
                        setWallProcess.command = ["bash", "-c", "$HOME/.config/quickshell/components/Scripts/set-wall.sh '" + model.filePath + "'"];
                        setWallProcess.running = false;
                        setWallProcess.running = true;
                    }
                }
            }
        }
    }
}