import QtQuick

Item {
    id: root
    property int brightnessLevel: 100
    property string themeAccent: "#89b4fa"
    property color trackColor: "#313244"
    property int appearanceMode: 0
    property color textColor: "#ffffff"

    Row {
        anchors.centerIn: parent
        spacing: 12

        Rectangle {
            width: 110
            height: 6
            radius: 3
            color: root.trackColor
            border.color: root.appearanceMode === 2 ? Qt.rgba(0, 0, 0, 0.3) : "transparent"
            border.width: root.appearanceMode === 2 ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: parent.width * (Math.max(0, Math.min(100, root.brightnessLevel)) / 100)
                height: parent.height
                radius: parent.radius
                color: root.themeAccent
                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutExpo } }
            }
        }

        Text {
            text: root.brightnessLevel + "%"
            color: root.textColor 
            font.family: "Inter"
            font.pixelSize: 12
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.brightnessLevel <= 0 ? "󰃛" : (root.brightnessLevel < 50 ? "󰃞" : "󰃠")
            color: root.themeAccent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}