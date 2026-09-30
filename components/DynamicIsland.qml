import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "Views"

Rectangle {
    id: root
    property int layoutStyle: 0
    property string activeMode: "compact"
    property int currentWorkspace: 1
    property string currentTime: Qt.formatTime(new Date(), "hh:mm")
    property string currentDate: Qt.formatDate(new Date(), "dddd, MMMM d")
    
    property int viewMonth: new Date().getMonth()
    property int viewYear: new Date().getFullYear()

    property int cpuUsage: 0
    property int ramUsage: 0
    property int swapUsage: 0
    property int batUsage: 100
    property int volumeLevel: 50
    property int brightnessLevel: 100

    property string rawAccent: "#89b4fa"
    property bool isWallpaperLight: false
    property color themeAccent: isWallpaperLight ? Qt.darker(rawAccent, 1.4) : Qt.lighter(rawAccent, 1.2)

    property int appearanceMode: 0 

    property color glassBgColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.08)
    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassSubTextColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(1, 1, 1, 0.6)
    property color glassTrackColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(0, 0, 0, 0.3)
    property color glassBorderOuter: isWallpaperLight ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.15)
    property color glassBorderInner: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.3)

    property color bgColor: appearanceMode === 0 ? "#1a1b26" : (appearanceMode === 1 ? "#f5f5f7" : glassBgColor)
    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color subTextColor: appearanceMode === 0 ? "#6c7086" : (appearanceMode === 1 ? "#86868b" : glassSubTextColor)
    property color trackColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#e8e8ed" : glassTrackColor)
    property color ringBgColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#e8e8ed" : glassTrackColor)

    implicitWidth: {
        switch(activeMode) {
            case "applauncher": return 850;
            case "calendar": return 320;
            case "fullcalendar": return 320;
            case "wallpapers": return 600;
            case "dashboard": return 900;
            case "performance": return 520;
            case "volume": return 220;
            case "brightness": return 220;
            case "clipboard": return 450;
            case "weather": return 440;
            default: return 140;
        }
    }
    implicitHeight: {
        switch(activeMode) {
            case "applauncher": return 480; 
            case "calendar": return 85;
            case "fullcalendar": return 350;
            case "wallpapers": return 260;
            case "dashboard": return 620;
            case "performance": return 140;
            case "volume": return 42;
            case "brightness": return 42;
            case "clipboard": return 380;
            case "weather": return 260;
            default: return 36;
        }
    }

    width: implicitWidth
    height: implicitHeight

    property int baseRadius: {
        switch(activeMode) {
            case "applauncher": return 24;
            case "calendar": return 24;
            case "fullcalendar": return 24;
            case "wallpapers": return 24;
            case "dashboard": return 24;
            case "clipboard": return 24;
            case "weather": return 24;
            case "performance": return 32;
            case "volume": return 21;
            case "brightness": return 21;
            default: return 18;
        }
    }

    topLeftRadius: layoutStyle === 1 ? 0 : baseRadius
    topRightRadius: layoutStyle === 1 ? 0 : baseRadius
    bottomLeftRadius: baseRadius
    bottomRightRadius: baseRadius

    color: root.bgColor
    border.color: root.appearanceMode === 2 ? "transparent" : root.themeAccent
    border.width: 1
    clip: true

    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on topLeftRadius { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on topRightRadius { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on bottomLeftRadius { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on bottomRightRadius { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on color { ColorAnimation { duration: 400 } }
    Behavior on border.color { ColorAnimation { duration: 400 } }

    MouseArea {
        anchors.fill: parent
        z: -99
        enabled: root.activeMode !== "compact"
        onClicked: {
            autoHideTimer.stop();
            shCompact.running = false;
            shCompact.running = true;
            root.activeMode = "compact";
            root.viewMonth = new Date().getMonth();
            root.viewYear = new Date().getFullYear();
        }
    }

    Timer {
        id: autoHideTimer
        interval: 5000
        running: root.activeMode !== "compact" && root.activeMode !== "dashboard" && root.activeMode !== "applauncher" && root.activeMode !== "clipboard" && root.activeMode !== "weather"
        repeat: false
        onTriggered: {
            if (root.activeMode === "dashboard" || root.activeMode === "applauncher" || root.activeMode === "clipboard" || root.activeMode === "weather") return;
            shCompact.running = false
            shCompact.running = true
            root.activeMode = "compact"
            root.viewMonth = new Date().getMonth();
            root.viewYear = new Date().getFullYear();
        }
    }

    Item {
        anchors.fill: parent
        visible: root.appearanceMode === 2
        
        Rectangle {
            anchors.fill: parent
            topLeftRadius: root.topLeftRadius; topRightRadius: root.topRightRadius
            bottomLeftRadius: root.bottomLeftRadius; bottomRightRadius: root.bottomRightRadius
            color: "transparent"; border.color: root.glassBorderOuter; border.width: 1
        }
        Rectangle {
            anchors.fill: parent; anchors.margins: 1 
            topLeftRadius: root.topLeftRadius > 0 ? root.topLeftRadius - 1 : 0
            topRightRadius: root.topRightRadius > 0 ? root.topRightRadius - 1 : 0
            bottomLeftRadius: root.bottomLeftRadius - 1; bottomRightRadius: root.bottomRightRadius - 1
            color: "transparent"; border.color: root.glassBorderInner; border.width: 1
        }
    }

    Timer {
        interval: 150
        running: true
        repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/island_mode");
            xhr.setRequestHeader("Cache-Control", "no-cache");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var mode = xhr.responseText.trim();
                    if (mode === "compact" || mode === "dashboard" || mode === "wallpapers" || mode === "applauncher" || mode === "calendar" || mode === "fullcalendar" || mode === "performance" || mode === "volume" || mode === "brightness" || mode === "clipboard" || mode === "weather") {
                        if (root.activeMode !== mode) {
                            root.activeMode = mode;
                            if (mode === "dashboard" || mode === "applauncher" || mode === "clipboard" || mode === "weather") {
                                autoHideTimer.stop();
                            } else {
                                autoHideTimer.restart();
                            }
                        }
                    }
                }
            }
            xhr.send();

            var vXhr = new XMLHttpRequest();
            vXhr.open("GET", "file:///tmp/island_vol");
            vXhr.setRequestHeader("Cache-Control", "no-cache");
            vXhr.onreadystatechange = function() {
                if (vXhr.readyState === XMLHttpRequest.DONE) {
                    var val = parseInt(vXhr.responseText.trim());
                    if (!isNaN(val) && root.volumeLevel !== val) {
                        root.volumeLevel = val;
                        if (root.activeMode === "compact" || root.activeMode === "volume") {
                            shVolumeMode.running = false;
                            shVolumeMode.running = true;
                            autoHideTimer.restart();
                        }
                    }
                }
            }
            vXhr.send();

            var bXhr = new XMLHttpRequest();
            bXhr.open("GET", "file:///tmp/island_bri");
            bXhr.setRequestHeader("Cache-Control", "no-cache");
            bXhr.onreadystatechange = function() {
                if (bXhr.readyState === XMLHttpRequest.DONE) {
                    var val = parseInt(bXhr.responseText.trim());
                    if (!isNaN(val) && root.brightnessLevel !== val) {
                        root.brightnessLevel = val;
                        if (root.activeMode === "compact" || root.activeMode === "brightness") {
                            shBrightnessMode.running = false;
                            shBrightnessMode.running = true;
                            autoHideTimer.restart();
                        }
                    }
                }
            }
            bXhr.send();

            var cXhr = new XMLHttpRequest();
            cXhr.open("GET", "file:///home/" + Quickshell.env("USER") + "/.config/quickshell/island_colors?t=" + new Date().getTime());
            cXhr.setRequestHeader("Cache-Control", "no-cache");
            cXhr.onreadystatechange = function() {
                if (cXhr.readyState === XMLHttpRequest.DONE) {
                    var data = cXhr.responseText.trim().split("|");
                    if (data.length >= 2) {
                        var hex = data[0].replace("#", "");
                        if (hex.length === 6) {
                            var r = parseInt(hex.substr(0, 2), 16);
                            var g = parseInt(hex.substr(2, 2), 16);
                            var b = parseInt(hex.substr(4, 2), 16);
                            var luminance = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
                            root.isWallpaperLight = (luminance > 128);
                        }
                        if (root.rawAccent !== data[1]) root.rawAccent = data[1];
                    }
                }
            }
            cXhr.send();
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = Qt.formatTime(new Date(), "hh:mm");
            root.currentDate = Qt.formatDate(new Date(), "dddd, MMMM d");

            shSysStats.running = false;
            shSysStats.running = true;

            var sXhr = new XMLHttpRequest();
            sXhr.open("GET", "file:///tmp/island_sys");
            sXhr.setRequestHeader("Cache-Control", "no-cache");
            sXhr.onreadystatechange = function() {
                if (sXhr.readyState === XMLHttpRequest.DONE) {
                    var data = sXhr.responseText.trim().split("|");
                    if (data.length >= 4) {
                        root.cpuUsage = parseInt(data[0]) || 0;
                        root.ramUsage = parseInt(data[1]) || 0;
                        root.swapUsage = parseInt(data[2]) || 0;
                        root.batUsage = parseInt(data[3]) || 100;
                    }
                }
            }
            sXhr.send();
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        onPositionChanged: {
            if (root.activeMode !== "dashboard" && root.activeMode !== "applauncher" && root.activeMode !== "clipboard" && root.activeMode !== "weather") {
                autoHideTimer.restart();
            }
        }
        onClicked: {
            if (root.activeMode === "applauncher" || root.activeMode === "clipboard" || root.activeMode === "weather") return;
            let nextMode = "compact"
            
            if (root.activeMode === "compact") {
                nextMode = "calendar"
            } else if (root.activeMode === "calendar") {
                nextMode = "fullcalendar"
            } else if (root.activeMode === "fullcalendar") {
                nextMode = "compact"
                root.viewMonth = new Date().getMonth();
                root.viewYear = new Date().getFullYear();
            } else {
                nextMode = "compact"
            }
            
            shCycle.nextMode = nextMode
            shCycle.running = false
            shCycle.running = true
            root.activeMode = nextMode
            
            if (nextMode === "dashboard" || nextMode === "applauncher" || nextMode === "clipboard" || nextMode === "weather") {
                autoHideTimer.stop();
            } else if (nextMode !== "compact") {
                autoHideTimer.restart();
            }
        }
    }

    CompactView {
        anchors.fill: parent
        opacity: root.activeMode === "compact" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        volumeLevel: root.volumeLevel
        currentTime: root.currentTime
        brightnessLevel: root.brightnessLevel
        themeAccent: root.themeAccent
    }

    PerformanceView {
        anchors.fill: parent
        opacity: root.activeMode === "performance" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        cpuUsage: root.cpuUsage
        ramUsage: root.ramUsage
        swapUsage: root.swapUsage
        batUsage: root.batUsage
        themeAccent: root.themeAccent
        ringBgColor: root.ringBgColor
        textColor: root.textColor
        appearanceMode: root.appearanceMode
    }

    VolumeView {
        anchors.fill: parent
        opacity: root.activeMode === "volume" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        volumeLevel: root.volumeLevel
        themeAccent: root.themeAccent
        trackColor: root.trackColor
        textColor: root.textColor
        appearanceMode: root.appearanceMode
    }

    BrightnessView {
        anchors.fill: parent
        opacity: root.activeMode === "brightness" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        brightnessLevel: root.brightnessLevel
        themeAccent: root.themeAccent
        trackColor: root.trackColor
        textColor: root.textColor
        appearanceMode: root.appearanceMode
    }

    DashboardView {
        anchors.fill: parent
        opacity: root.activeMode === "dashboard" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
        
        themeAccent: root.themeAccent
        appearanceMode: root.appearanceMode 
    }

    CalendarCompactView {
        anchors.fill: parent
        opacity: root.activeMode === "calendar" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        currentDate: root.currentDate
        themeAccent: root.themeAccent
    }

    CalendarFullView {
        anchors.fill: parent
        opacity: root.activeMode === "fullcalendar" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        viewMonth: root.viewMonth
        viewYear: root.viewYear
        themeAccent: root.themeAccent
        appearanceMode: root.appearanceMode
        textColor: root.textColor
        subTextColor: root.subTextColor

        onInteracted: autoHideTimer.restart()
        onPreviousMonth: {
            if (root.viewMonth === 0) {
                root.viewMonth = 11;
                root.viewYear--;
            } else {
                root.viewMonth--;
            }
        }
        onNextMonth: {
            if (root.viewMonth === 11) {
                root.viewMonth = 0;
                root.viewYear++;
            } else {
                root.viewMonth++;
            }
        }
    }

    AppLauncher {
        anchors.fill: parent
        opacity: root.activeMode === "applauncher" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
        
        themeAccent: root.themeAccent
        appearanceMode: root.appearanceMode 
    }

    WallpapersView {
        anchors.fill: parent
        opacity: root.activeMode === "wallpapers" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        themeAccent: root.themeAccent

        onInteracted: autoHideTimer.restart()
        onWallpaperSelected: (path) => {
            shSetWallpaper.command = ["bash", "-c", "$HOME/.config/quickshell/components/Scripts/set-wall.sh '" + path + "'"]
            shSetWallpaper.running = false;
            shSetWallpaper.running = true;
        }
    }

    ClipboardView {
        anchors.fill: parent
        opacity: root.activeMode === "clipboard" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        themeAccent: root.themeAccent
        appearanceMode: root.appearanceMode
        isWallpaperLight: root.isWallpaperLight
    }

    WeatherView {
        anchors.fill: parent
        opacity: root.activeMode === "weather" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

        themeAccent: root.themeAccent
        appearanceMode: root.appearanceMode
        isWallpaperLight: root.isWallpaperLight
    }

    Process { id: shCompact; command: ["bash", "-c", "echo 'compact' > /tmp/island_mode"] }
    Process { id: shSysStats; command: ["bash", "-c", "$HOME/.config/quickshell/components/Scripts/sys-stats.sh"] }
    Process { id: shVolumeMode; command: ["bash", "-c", "echo 'volume' > /tmp/island_mode"] }
    Process { id: shBrightnessMode; command: ["bash", "-c", "echo 'brightness' > /tmp/island_mode"] }
    Process { 
        id: shCycle
        property string nextMode: "compact"
        command: ["bash", "-c", "echo '" + nextMode + "' > /tmp/island_mode"]
    }
    Process { id: shSetWallpaper }
}