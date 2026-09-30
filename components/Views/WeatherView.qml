import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: weatherRoot
    width: parent.width
    height: 260

    property string themeAccent: "#89b4fa"
    property int appearanceMode: 0 
    property bool isWallpaperLight: false

    property color glassBgColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05)
    property color glassBorderColor: isWallpaperLight ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.15)
    property color glassInnerBg: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(0, 0, 0, 0.15)
    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassSubTextColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(1, 1, 1, 0.7)

    property color cardBgColor: appearanceMode === 0 ? "#181825" : (appearanceMode === 1 ? "#e8e8ed" : glassBgColor)
    property color cardBorderColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassBorderColor)
    property color innerBgColor: appearanceMode === 0 ? "#1a1b26" : (appearanceMode === 1 ? "#ffffff" : glassInnerBg)
    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color subTextColor: appearanceMode === 0 ? "#6c7086" : (appearanceMode === 1 ? "#86868b" : glassSubTextColor)

    property string curLocation: "--"
    property string curTemp: "--"
    property string curHum: "--"
    property string curApp: "--"
    property string curWind: "--"
    property string curIcon: ""
    property string curDesc: "Loading..."

    ListModel {
        id: hourlyModel
    }

    function getWeatherIcon(code) {
        if (code === 0) return ["", "Clear sky"];
        if (code === 1 || code === 2 || code === 3) return ["", "Partly cloudy"];
        if (code === 45 || code === 48) return ["", "Fog"];
        if (code >= 51 && code <= 57) return ["", "Drizzle"];
        if (code >= 61 && code <= 67) return ["", "Rain"];
        if (code >= 71 && code <= 77) return ["", "Snow"];
        if (code >= 80 && code <= 82) return ["", "Showers"];
        if (code >= 85 && code <= 86) return ["", "Snow showers"];
        if (code >= 95) return ["", "Thunderstorm"];
        return ["", "Unknown"];
    }

    component DarkFrostOverlay: Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        visible: weatherRoot.appearanceMode === 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
            GradientStop { position: 1.0; color: weatherRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
        }
        border.color: weatherRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: weatherRoot.isWallpaperLight ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
        }
    }

    Rectangle {
        anchors.fill: parent
        color: weatherRoot.cardBgColor
        radius: 16
        border.color: weatherRoot.cardBorderColor
        border.width: 1

        DarkFrostOverlay {}

        Row {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 24
            spacing: 20

            Text {
                text: curIcon
                color: weatherRoot.themeAccent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 52
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { text: curLocation; color: weatherRoot.subTextColor; font.family: "Inter"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.2; font.capitalization: Font.AllUppercase }
                Text { text: curTemp + "°C"; color: weatherRoot.textColor; font.family: "Inter"; font.pixelSize: 32; font.bold: true }
                Text { text: curDesc; color: weatherRoot.subTextColor; font.family: "Inter"; font.pixelSize: 14 }
            }

            Item { width: 10; height: 1 }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text { text: "󰖐  Feels like: " + curApp + "°"; color: weatherRoot.subTextColor; font.family: "Inter"; font.pixelSize: 12 }
                Text { text: "  Humidity: " + curHum + "%"; color: weatherRoot.subTextColor; font.family: "Inter"; font.pixelSize: 12 }
                Text { text: "  Wind: " + curWind + " km/h"; color: weatherRoot.subTextColor; font.family: "Inter"; font.pixelSize: 12 }
            }
        }

        Row {
            id: hourlyRow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            
            Repeater {
                model: hourlyModel
                Rectangle {
                    width: 52
                    height: 84
                    radius: 12
                    color: index === 3 ? weatherRoot.themeAccent : weatherRoot.innerBgColor
                    border.color: index === 3 ? "transparent" : weatherRoot.cardBorderColor
                    border.width: weatherRoot.appearanceMode === 2 && index !== 3 ? 0 : 1
                    
                    Rectangle {
                        anchors.fill: parent; radius: parent.radius; color: "transparent"
                        visible: weatherRoot.appearanceMode === 2 && index !== 3
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                            GradientStop { position: 1.0; color: weatherRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.2) }
                        }
                        border.color: weatherRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.3) : Qt.rgba(0, 0, 0, 0.3)
                        border.width: 1
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { 
                            text: timeStr; 
                            color: index === 3 ? (weatherRoot.appearanceMode === 2 ? "#1a1b26" : "#1a1b26") : weatherRoot.subTextColor; 
                            font.family: "Inter"; font.pixelSize: 11; font.bold: index === 3; anchors.horizontalCenter: parent.horizontalCenter 
                        }
                        Text { 
                            text: iconStr; 
                            color: index === 3 ? (weatherRoot.appearanceMode === 2 ? "#1a1b26" : "#1a1b26") : weatherRoot.themeAccent; 
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter 
                        }
                        Text { 
                            text: tempStr + "°"; 
                            color: index === 3 ? (weatherRoot.appearanceMode === 2 ? "#1a1b26" : "#1a1b26") : weatherRoot.textColor; 
                            font.family: "Inter"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter 
                        }
                    }
                }
            }
        }
    }

    Process {
        id: fetchWeather
        command: ["bash", "-c", "python3 $HOME/.config/quickshell/components/Scripts/weather.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim();
                if (out === "") return;
                var parts = out.split("||");
                if (parts.length < 2) return;
                
                var curr = parts[0].split("|");
                var hourly = parts[1].split("|");
                
                if (curr.length >= 6) {
                    weatherRoot.curLocation = curr[0];
                    weatherRoot.curTemp = curr[1];
                    weatherRoot.curHum = curr[2];
                    weatherRoot.curApp = curr[3];
                    weatherRoot.curWind = curr[4];
                    var w = weatherRoot.getWeatherIcon(parseInt(curr[5]));
                    weatherRoot.curIcon = w[0];
                    weatherRoot.curDesc = w[1];
                } else if (curr.length >= 5) {
                    weatherRoot.curTemp = curr[0];
                    weatherRoot.curHum = curr[1];
                    weatherRoot.curApp = curr[2];
                    weatherRoot.curWind = curr[3];
                    var w2 = weatherRoot.getWeatherIcon(parseInt(curr[4]));
                    weatherRoot.curIcon = w2[0];
                    weatherRoot.curDesc = w2[1];
                }
                
                hourlyModel.clear();
                for (var i = 0; i < hourly.length; i++) {
                    var hParts = hourly[i].split(",");
                    if (hParts.length >= 3) {
                        var hw = weatherRoot.getWeatherIcon(parseInt(hParts[2]));
                        hourlyModel.append({
                            timeStr: hParts[0],
                            tempStr: Math.round(parseFloat(hParts[1])).toString(),
                            iconStr: hw[0]
                        });
                    }
                }
            }
        }
    }

    Timer {
        id: initTimer
        interval: 350
        running: weatherRoot.visible
        repeat: false
        onTriggered: {
            fetchWeather.running = false;
            fetchWeather.running = true;
        }
    }

    Timer {
        interval: 900000
        running: weatherRoot.visible
        repeat: true
        onTriggered: {
            fetchWeather.running = false;
            fetchWeather.running = true;
        }
    }
}