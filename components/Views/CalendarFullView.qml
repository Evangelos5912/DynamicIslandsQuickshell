import QtQuick

Item {
    id: root
    property int viewMonth: 0
    property int viewYear: 0
    property string themeAccent: "#89b4fa"
    property int appearanceMode: 0
    property bool isWallpaperLight: false

    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassSubTextColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(1, 1, 1, 0.6)

    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color subTextColor: appearanceMode === 0 ? "#6c7086" : (appearanceMode === 1 ? "#86868b" : glassSubTextColor)

    signal interacted()
    signal previousMonth()
    signal nextMonth()

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Row {
            width: parent.width
            
            Rectangle {
                width: 30; height: 30; radius: 15; color: "transparent"
                Text { anchors.centerIn: parent; text: "󰅁"; color: root.themeAccent; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.interacted();
                        root.previousMonth();
                    }
                }
            }

            Text {
                width: parent.width - 60
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                height: 30
                text: {
                    var d = new Date(root.viewYear, root.viewMonth, 1);
                    return Qt.formatDate(d, "MMMM yyyy");
                }
                color: root.themeAccent
                font.family: "Inter"
                font.pixelSize: 16
                font.bold: true
            }

            Rectangle {
                width: 30; height: 30; radius: 15; color: "transparent"
                Text { anchors.centerIn: parent; text: "󰅂"; color: root.themeAccent; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.interacted();
                        root.nextMonth();
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: 0
            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                Text {
                    width: parent.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: root.subTextColor 
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        Grid {
            width: parent.width
            columns: 7
            rowSpacing: 8
            
            Repeater {
                model: 42
                Item {
                    width: parent.width / 7
                    height: 30
                    
                    property int firstDay: new Date(root.viewYear, root.viewMonth, 1).getDay()
                    property int daysInMonth: new Date(root.viewYear, root.viewMonth + 1, 0).getDate()
                    property int daysInPrevMonth: new Date(root.viewYear, root.viewMonth, 0).getDate()
                    
                    property bool isCurrentMonth: index >= firstDay && index < firstDay + daysInMonth
                    property int dayNum: {
                        if (index < firstDay) return daysInPrevMonth - (firstDay - 1 - index);
                        if (index >= firstDay + daysInMonth) return index - (firstDay + daysInMonth) + 1;
                        return index - firstDay + 1;
                    }
                    
                    property bool isToday: {
                        var today = new Date();
                        return isCurrentMonth && dayNum === today.getDate() && root.viewMonth === today.getMonth() && root.viewYear === today.getFullYear();
                    }
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: 28; height: 28; radius: 14
                        color: isToday ? root.themeAccent : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: dayNum
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.bold: isToday
                            color: isToday 
                                ? (root.appearanceMode === 2 ? "#1a1b26" : "#1a1b26") 
                                : (isCurrentMonth ? root.textColor : root.subTextColor)
                        }
                    }
                }
            }
        }
    }
}