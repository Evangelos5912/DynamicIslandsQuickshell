import QtQuick

Item {
    id: root
    property string currentDate: ""
    property string themeAccent: "#89b4fa"
    
    Row {
        anchors.centerIn: parent
        spacing: 15
        
        Repeater {
            model: 5
            Item {
                id: dayItem
                width: 45
                height: 60
                
                property int offset: index - 2
                property string _trigger: root.currentDate 
                property var dateObj: {
                    var dummy = _trigger; 
                    var d = new Date();
                    d.setDate(d.getDate() + offset);
                    return d;
                }

                property bool isToday: index === 2
                
                opacity: isToday ? 1.0 : (Math.abs(offset) === 1 ? 0.5 : 0.2)
                scale: isToday ? 1.1 : 0.95
                
                Behavior on opacity { NumberAnimation { duration: 300 } }
                Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: Qt.formatDate(dayItem.dateObj, "MMM"); color: root.themeAccent; font.family: "Inter"; font.pixelSize: 11; font.bold: dayItem.isToday; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: Qt.formatDate(dayItem.dateObj, "ddd"); color: root.themeAccent; font.family: "Inter"; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: Qt.formatDate(dayItem.dateObj, "d"); color: root.themeAccent; font.family: "Inter"; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }
        }
    }
}