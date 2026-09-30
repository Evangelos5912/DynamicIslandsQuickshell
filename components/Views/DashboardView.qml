import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray

Item {
    id: dashboardRoot
    anchors.fill: parent

    property string themeAccent: "#89b4fa"
    property int appearanceMode: 0 
    property bool isWallpaperLight: false

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

    function getTasksArray() {
        var jsonParts = [];
        for (var i = 0; i < todoModel.count; i++) {
            var item = todoModel.get(i);
            var textEscaped = item.taskText.replace(/["\\]/g, '\\$&');
            jsonParts.push("{\"taskText\": \"" + textEscaped + "\", \"isDone\": " + item.isDone + "}");
        }
        return "[" + jsonParts.join(",") + "]";
    }

    function saveTasks() {
        var jsonStr = getTasksArray();
        saveProc.command = ["bash", "-c", "mkdir -p ~/.config/quickshell && cat << 'EOF' > ~/.config/quickshell/tasks.json\n" + jsonStr + "\nEOF"];
        saveProc.running = false;
        saveProc.running = true;
    }

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///home/" + Quickshell.env("USER") + "/.config/quickshell/tasks.json?t=" + new Date().getTime());
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.responseText) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (Array.isArray(data) && data.length > 0) {
                        todoModel.clear();
                        for (var i = 0; i < data.length; i++) {
                            todoModel.append(data[i]);
                        }
                    }
                } catch (e) {}
            }
        }
        xhr.send();
    }

    component DarkFrostOverlay: Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        visible: dashboardRoot.appearanceMode === 2
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
            GradientStop { position: 0.7; color: dashboardRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 1.0; color: dashboardRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
        }
        
        border.color: dashboardRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: dashboardRoot.isWallpaperLight ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Rectangle {
            width: parent.width
            height: 80
            color: dashboardRoot.cardBgColor
            radius: 16
            border.color: dashboardRoot.cardBorderColor
            border.width: 1

            DarkFrostOverlay {}

            Row {
                anchors.centerIn: parent
                spacing: 35

                PowerButton { icon: "󰐥"; actionCmd: ["/usr/bin/systemctl", "poweroff"] }
                PowerButton { icon: "󰜉"; actionCmd: ["/usr/bin/systemctl", "reboot"] }
                PowerButton { icon: "󰍃"; actionCmd: ["/usr/bin/hyprctl", "dispatch", "hl.dsp.exit()"] }
                PowerButton { icon: "󰑓"; actionCmd: ["/usr/bin/hyprctl", "reload"] }
            }
        }

        Rectangle {
            width: parent.width
            height: 200
            color: dashboardRoot.cardBgColor
            radius: 16
            border.color: dashboardRoot.cardBorderColor
            border.width: 1
            clip: true

            DarkFrostOverlay {}
            
            NotificationServer {
                id: notifServer
                onNotification: (notification) => {
                    notification.tracked = true
                }
            }
            
            Text {
                id: notifTitle
                text: "NOTIFICATIONS"
                color: dashboardRoot.subTextColor
                font.family: "Inter"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.2
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 16
            }

            Column {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 8
                spacing: 12
                visible: notifList.count === 0

                Text {
                    text: "󰂚"
                    color: dashboardRoot.subTextColor
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 36
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0.5
                }

                Text {
                    text: "No new notifications"
                    color: dashboardRoot.subTextColor
                    font.family: "Inter"
                    font.pixelSize: 13
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ListView {
                id: notifList
                anchors.top: notifTitle.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14
                anchors.topMargin: 10
                spacing: 8
                clip: true
                visible: count > 0
                
                model: notifServer.trackedNotifications
                
                delegate: Rectangle {
                    width: notifList ? notifList.width : parent.width
                    height: Math.max(60, contentRow.implicitHeight + 20)
                    color: dashboardRoot.appearanceMode === 2 ? "transparent" : dashboardRoot.innerBgColor
                    radius: 12
                    border.color: dashboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.2) : dashboardRoot.cardBorderColor
                    border.width: 1

                    DarkFrostOverlay {}

                    Row {
                        id: contentRow
                        anchors.left: parent.left
                        anchors.right: closeBtn.left
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 12

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: dashboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.05) : dashboardRoot.cardBgColor
                            clip: true
                            border.color: dashboardRoot.appearanceMode === 2 ? Qt.rgba(0,0,0,0.2) : "transparent"
                            border.width: 1
                            
                            Image {
                                anchors.fill: parent
                                source: modelData.icon ? (modelData.icon.startsWith("/") ? "file://" + modelData.icon : modelData.icon) : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: modelData.icon !== "" && modelData.icon !== undefined
                                asynchronous: true
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    var app = modelData.appName ? modelData.appName.toLowerCase() : "";
                                    if (app.indexOf("discord") !== -1) return "";
                                    if (app.indexOf("spotify") !== -1) return "";
                                    if (app.indexOf("slack") !== -1) return "";
                                    if (app.indexOf("mail") !== -1) return "󰊫";
                                    if (app.indexOf("volume") !== -1) return "󰕾";
                                    return "󰂚";
                                }
                                color: dashboardRoot.themeAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18
                                visible: !modelData.icon || modelData.icon === ""
                            }
                        }

                        Column {
                            width: parent.width - 48 
                            spacing: 2

                            Text {
                                text: (modelData.appName ? modelData.appName : "System").toUpperCase()
                                color: dashboardRoot.themeAccent
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 0.5
                            }
                            
                            Text {
                                text: modelData.summary ? modelData.summary : ""
                                color: dashboardRoot.textColor
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: modelData.body ? modelData.body.replace(/<[^>]*>?/gm, '') : ""
                                color: dashboardRoot.subTextColor
                                font.family: "Inter"
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                    }

                    MouseArea {
                        id: closeBtn
                        width: 24
                        height: 24
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 8
                        cursorShape: Qt.PointingHandCursor
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: closeBtn.containsMouse ? "#f38ba8" : dashboardRoot.subTextColor
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        
                        onClicked: {
                            modelData.tracked = false
                        }
                    }
                }
            }
        }
        
        Rectangle {
            width: parent.width
            height: parent.height - 80 - 200 - 90 - 60 
            color: dashboardRoot.cardBgColor
            radius: 16
            border.color: dashboardRoot.cardBorderColor
            border.width: 1
            clip: true

            DarkFrostOverlay {}
            
            Text {
                id: taskTitle
                text: "TASKS"
                color: dashboardRoot.subTextColor
                font.family: "Inter"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.2
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 16
            }

            Column {
                anchors.top: taskTitle.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14
                anchors.topMargin: 10
                spacing: 12

                Rectangle {
                    width: parent.width
                    height: 36
                    color: dashboardRoot.appearanceMode === 2 ? "transparent" : dashboardRoot.innerBgColor
                    radius: 8
                    border.color: dashboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.2) : dashboardRoot.cardBorderColor
                    border.width: 1

                    DarkFrostOverlay {}

                    TextInput {
                        id: taskInput
                        anchors.fill: parent
                        anchors.margins: 10
                        color: dashboardRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 12
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        
                        Text {
                            text: "Add a task..."
                            color: dashboardRoot.subTextColor
                            font.family: "Inter"
                            font.pixelSize: 12
                            visible: !taskInput.text && !taskInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: 0.7
                        }

                        onAccepted: {
                            if (text.trim() !== "") {
                                todoModel.append({ "taskText": text.trim(), "isDone": false });
                                text = "";
                                dashboardRoot.saveTasks();
                            }
                        }
                    }
                }

                ListView {
                    id: taskListView
                    width: parent.width
                    height: parent.height - 48
                    spacing: 10
                    clip: true
                    model: ListModel { id: todoModel }
                    
                    delegate: Rectangle {
                        width: taskListView ? taskListView.width : parent.width
                        height: 38
                        color: dashboardRoot.appearanceMode === 2 ? "transparent" : dashboardRoot.innerBgColor
                        radius: 8
                        border.color: dashboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.2) : dashboardRoot.cardBorderColor
                        border.width: 1

                        DarkFrostOverlay {}

                        Row {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10
                            
                            Rectangle {
                                width: 20; height: 20; radius: 6
                                color: isDone ? dashboardRoot.themeAccent : (dashboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                                border.color: isDone ? dashboardRoot.themeAccent : dashboardRoot.subTextColor
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    color: dashboardRoot.appearanceMode === 0 ? "#1a1b26" : "#ffffff"
                                    visible: isDone
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        todoModel.setProperty(index, "isDone", !isDone);
                                        dashboardRoot.saveTasks();
                                    }
                                }
                            }
                            
                            Text {
                                text: taskText
                                color: isDone ? dashboardRoot.subTextColor : dashboardRoot.textColor
                                font.family: "Inter"
                                font.pixelSize: 13
                                width: parent.width - 60
                                wrapMode: Text.Wrap
                                anchors.verticalCenter: parent.verticalCenter
                                font.strikeout: isDone
                            }

                            Rectangle {
                                width: 20; height: 20; radius: 6
                                color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰆴"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    color: delMouseArea.containsMouse ? "#f38ba8" : dashboardRoot.subTextColor
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea {
                                    id: delMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        todoModel.remove(index);
                                        dashboardRoot.saveTasks();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 90
            color: dashboardRoot.cardBgColor
            radius: 16
            border.color: dashboardRoot.cardBorderColor
            border.width: 1
            clip: false 

            DarkFrostOverlay {}

            Text {
                id: trayTitle
                text: "BACKGROUND APPS"
                color: dashboardRoot.subTextColor
                font.family: "Inter"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.2
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 16
            }

            ListView {
                id: trayList
                anchors.top: trayTitle.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                anchors.topMargin: 6
                spacing: 10
                orientation: ListView.Horizontal
                clip: false 
                
                model: SystemTray.items
                
                delegate: Rectangle {
                    id: trayCard
                    width: 48
                    height: 48
                    radius: 12
                    
                    property bool isDying: false
                    property bool menuOpen: false
                    property bool isHovered: cardMouse.containsMouse || (openBtnMouse && openBtnMouse.containsMouse) || (quitBtnMouse && quitBtnMouse.containsMouse)
                    
                    opacity: isDying ? 0.4 : 1.0
                    color: dashboardRoot.appearanceMode === 2 ? "transparent" : (isHovered || menuOpen ? dashboardRoot.innerHoverColor : dashboardRoot.innerBgColor)
                    border.color: dashboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.2) : (isHovered || menuOpen ? dashboardRoot.themeAccent : dashboardRoot.cardBorderColor)
                    border.width: 1
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    DarkFrostOverlay {}

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: dashboardRoot.themeAccent
                        border.width: 1
                        visible: dashboardRoot.appearanceMode === 2 && (trayCard.isHovered || trayCard.menuOpen)
                    }

                    Timer {
                        interval: 150
                        running: !trayCard.isHovered && trayCard.menuOpen
                        onTriggered: trayCard.menuOpen = false
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: trayCard.menuOpen ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: {
                            if (!trayCard.isDying && !trayCard.menuOpen) {
                                trayCard.menuOpen = true;
                            }
                        }
                    }

                    Item {
                        anchors.fill: parent
                        visible: !trayCard.menuOpen

                        Image {
                            id: trayIcon
                            anchors.centerIn: parent
                            width: 24; height: 24
                            asynchronous: true
                            source: {
                                var rawId = (modelData.id || modelData.title || "").toLowerCase();
                                if (rawId.indexOf("discord") !== -1 || rawId.indexOf("vencord") !== -1) return "image://icon/discord";
                                if (rawId.indexOf("spotify") !== -1) return "image://icon/spotify";
                                if (rawId.indexOf("steam") !== -1) return "image://icon/steam";
                                if (rawId.indexOf("slack") !== -1) return "image://icon/slack";

                                var icn = modelData.icon || "";
                                if (icn !== "") {
                                    if (icn.startsWith("file://") || icn.startsWith("/")) {
                                        return icn.startsWith("/") ? "file://" + icn : icn;
                                    }
                                    return "image://icon/" + icn;
                                } 
                                
                                var cleanId = rawId.replace(/[0-9]+$/, '');
                                return "image://icon/" + cleanId;
                            }
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            visible: trayIcon.status === Image.Error || trayIcon.source == ""
                            text: (modelData.id || modelData.title || "?").charAt(0).toUpperCase()
                            color: dashboardRoot.themeAccent
                            font.family: "Inter"
                            font.bold: true
                            font.pixelSize: 18
                        }

                        Rectangle {
                            visible: trayCard.isHovered && !trayCard.isDying
                            color: dashboardRoot.appearanceMode === 0 ? "#1a1b26" : "#ffffff"
                            border.color: dashboardRoot.themeAccent
                            border.width: 1
                            radius: 6
                            width: tooltipText.width + 16
                            height: 24
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            z: 100
                            Text {
                                id: tooltipText
                                anchors.centerIn: parent
                                text: modelData.title || modelData.id || "Unknown App"
                                color: dashboardRoot.appearanceMode === 0 ? "#cdd6f4" : "#1d1d1f"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "Inter"
                            }
                        }
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 4
                        visible: trayCard.menuOpen && !trayCard.isDying

                        Rectangle {
                            width: parent.width
                            height: 20
                            radius: 8
                            color: openBtnMouse.containsMouse ? dashboardRoot.themeAccent : "transparent"
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { 
                                    text: "󰒋"
                                    color: openBtnMouse.containsMouse ? (dashboardRoot.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : dashboardRoot.themeAccent
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.bold: true 
                                }
                                Text { 
                                    text: "Open"
                                    color: openBtnMouse.containsMouse ? (dashboardRoot.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : dashboardRoot.textColor
                                    font.family: "Inter"; font.pixelSize: 10; font.bold: true 
                                }
                            }

                            MouseArea {
                                id: openBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    modelData.activate();
                                    trayCard.menuOpen = false;
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 20
                            radius: 8
                            color: quitBtnMouse.containsMouse ? "#f38ba8" : "transparent"
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { 
                                    text: "󰅖"
                                    color: quitBtnMouse.containsMouse ? (dashboardRoot.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : "#f38ba8"
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.bold: true 
                                }
                                Text { 
                                    text: "Quit"
                                    color: quitBtnMouse.containsMouse ? (dashboardRoot.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : "#f38ba8"
                                    font.family: "Inter"; font.pixelSize: 10; font.bold: true 
                                }
                            }

                            MouseArea {
                                id: quitBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    trayCard.menuOpen = false;
                                    trayCard.isDying = true;
                                    
                                    var rawName = (modelData.id || modelData.title || "").toLowerCase();
                                    var procName = rawName.replace(/[0-9]+$/, '').trim();
                                    
                                    if (procName.indexOf("discord") !== -1 || procName.indexOf("vencord") !== -1) procName = "discord";
                                    else if (procName.indexOf("spotify") !== -1) procName = "spotify";
                                    else if (procName.indexOf("steam") !== -1) procName = "steam";
                                    else if (procName.indexOf("slack") !== -1) procName = "slack";
                                    else if (procName.indexOf("telegram") !== -1) procName = "telegram";
                                    
                                    if (procName !== "") {
                                        killProc.command = ["bash", "-c", "pkill -f -i '" + procName + "' || killall -9 -I '" + procName + "' &"];
                                        killProc.running = false;
                                        killProc.running = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 8
                visible: trayList.count === 0
                text: "No background apps running"
                color: dashboardRoot.subTextColor
                font.family: "Inter"
                font.pixelSize: 13
            }
        }
    }

    component PowerButton: Rectangle {
        property string icon: ""
        property var actionCmd: []

        width: 48
        height: 48
        radius: 24
        color: dashboardRoot.appearanceMode === 2 ? "transparent" : (mouseArea.containsMouse ? dashboardRoot.innerHoverColor : dashboardRoot.innerBgColor)
        border.color: dashboardRoot.appearanceMode === 2 ? Qt.rgba(1, 1, 1, 0.2) : (mouseArea.containsMouse ? dashboardRoot.themeAccent : dashboardRoot.cardBorderColor)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        DarkFrostOverlay {}

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: dashboardRoot.themeAccent
            border.width: 1
            visible: dashboardRoot.appearanceMode === 2 && mouseArea.containsMouse
        }

        Text {
            anchors.centerIn: parent
            text: icon
            color: mouseArea.containsMouse ? dashboardRoot.themeAccent : dashboardRoot.textColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18

            Behavior on color { ColorAnimation { duration: 200 } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                powerProc.command = actionCmd
                powerProc.running = false
                powerProc.running = true
            }
        }
    }

    property var liveWindows: []

    Timer {
        id: startupDumpTimer
        interval: 350
        running: dashboardRoot.visible
        repeat: false
        onTriggered: { clientsDumpProc.running = false; clientsDumpProc.running = true; }
    }

    Timer {
        interval: 1000
        running: dashboardRoot.visible && !dashboardRoot.isSearching && !dashboardRoot.isDraggingWindow 
        repeat: true
        onTriggered: { clientsDumpProc.running = false; clientsDumpProc.running = true; }
    }

    Process { 
        id: clientsDumpProc 
        command: ["bash", "-c", "hyprctl clients -j > /tmp/island_clients.json"]
        onExited: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/island_clients.json?t=" + new Date().getTime());
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    try { dashboardRoot.liveWindows = JSON.parse(xhr.responseText); } catch(e) { dashboardRoot.liveWindows = []; }
                }
            }
            xhr.send();
        }
    }

    Process { id: powerProc }
    Process { id: saveProc }
    Process { id: killProc }
}