import QtQuick

Item {
    id: root
    property int cpuUsage: 0
    property int ramUsage: 0
    property int swapUsage: 0
    property int batUsage: 100
    property string themeAccent: "#89b4fa"
    property color ringBgColor: "#313244"
    property color textColor: "#ffffff"
    property int appearanceMode: 0

    Row {
        anchors.centerIn: parent
        spacing: 16

        StatRing { label: "CPU"; icon: ""; value: root.cpuUsage; accent: root.themeAccent }
        StatRing { label: "RAM"; icon: ""; value: root.ramUsage; accent: root.themeAccent }
        StatRing { label: "SWAP"; icon: "󰓡"; value: root.swapUsage; accent: root.themeAccent }
        StatRing { label: "BAT"; icon: "󰁹"; value: root.batUsage; accent: root.themeAccent }
    }

    component StatRing: Item {
        property string label: ""
        property string icon: ""
        property int value: 0
        property color accent: "#89b4fa"

        width: 105
        height: 105

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: root.ringBgColor
            border.width: 6
            Behavior on border.color { ColorAnimation { duration: 400 } }
            
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1 
                radius: width / 2
                color: "transparent"
                border.color: Qt.rgba(0, 0, 0, 0.4)
                border.width: 1
                visible: root.appearanceMode === 2
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            property real progress: Math.max(0, Math.min(100, value)) / 100
            onProgressChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                if (progress <= 0) return;
                ctx.beginPath();
                var startAngle = -Math.PI / 2;
                var endAngle = startAngle + (2 * Math.PI * progress);
                ctx.arc(width / 2, height / 2, width / 2 - 3, startAngle, endAngle, false);
                ctx.strokeStyle = accent;
                ctx.lineWidth = 6;
                ctx.stroke();
            }
            Behavior on progress { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
        }

        Column {
            anchors.centerIn: parent
            spacing: 2
            Text {
                text: icon
                color: accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 32
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on color { ColorAnimation { duration: 400 } }
            }
            Text {
                text: value + "%"
                color: root.textColor 
                font.family: "Inter"
                font.pixelSize: 12
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}