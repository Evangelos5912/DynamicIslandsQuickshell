import QtQuick

Item {
    id: root
    property int volumeLevel: 50
    property string currentTime: ""
    property int brightnessLevel: 100
    property string themeAccent: "#89b4fa"

    Row {
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: root.volumeLevel <= 0 ? "󰝟" : (root.volumeLevel < 30 ? "󰕿" : (root.volumeLevel < 70 ? "󰖀" : "󰕾"))
            color: root.themeAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }

        Text { 
            text: root.currentTime
            color: root.themeAccent
            font.family: "Inter"
            font.pixelSize: 16
            font.bold: true 
        }

        Text {
            text: root.brightnessLevel <= 0 ? "󰃛" : (root.brightnessLevel < 50 ? "󰃞" : "󰃠")
            color: root.themeAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }
    }
}