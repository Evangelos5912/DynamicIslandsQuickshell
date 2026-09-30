import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: btRoot
    width: parent.width
    height: parent.height

    property var rootRef: parent.parent !== undefined ? parent.parent : null
    
    property string themeAccent: rootRef ? rootRef.themeAccent : "#89b4fa"
    property int appearanceMode: rootRef ? rootRef.appearanceMode : 0 
    property bool isWallpaperLight: rootRef ? rootRef.isWallpaperLight : false
    
    property color glassBorderInner: rootRef ? rootRef.glassBorderInner : Qt.rgba(1, 1, 1, 0.3)
    property color bgColor: rootRef ? rootRef.bgColor : "#1a1b26"
    property color btnColor: rootRef ? rootRef.btnColor : "#181825"
    property color btnHoverColor: rootRef ? rootRef.btnHoverColor : "#313244"
    property color trackColor: rootRef ? rootRef.trackColor : "#313244"

    property color textColor: appearanceMode === 1 ? "#1d1d1f" : (appearanceMode === 2 && isWallpaperLight ? "#1a1b26" : "#ffffff")
    property color subTextColor: appearanceMode === 1 ? Qt.rgba(0, 0, 0, 0.6) : (appearanceMode === 2 && isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(255, 255, 255, 0.6))

    property color cardBgColor: appearanceMode === 0 ? "#181825" : (appearanceMode === 1 ? "#e8e8ed" : (isWallpaperLight ? Qt.rgba(0,0,0,0.1) : Qt.rgba(1,1,1,0.05)))
    property color cardBorderColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : (isWallpaperLight ? Qt.rgba(1,1,1,0.3) : Qt.rgba(0,0,0,0.15)))
    property color innerBgColor: appearanceMode === 0 ? "#1a1b26" : (appearanceMode === 1 ? "#ffffff" : (isWallpaperLight ? Qt.rgba(0,0,0,0.05) : Qt.rgba(0,0,0,0.15)))
    property color innerHoverColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : (isWallpaperLight ? Qt.rgba(0,0,0,0.15) : Qt.rgba(1,1,1,0.1)))

    property bool isBtOn: true
    property bool isInitialFetch: true
    
    property string activeDeviceName: ""
    property string activeDeviceMac: ""
    property string activeDeviceIconType: "default"
    
    property string connectingMac: ""

    ListModel {
        id: btModel
    }

    Timer {
        id: asyncTask
        interval: 50
        property string pendingCmd: ""
        onTriggered: {
            if (pendingCmd !== "") {
                actionProc.command = ["bash", "-c", pendingCmd];
                actionProc.running = false;
                actionProc.running = true;
            }
        }
    }

    Timer {
        id: delayedRefreshTimer
        interval: 2500 
        repeat: false
        onTriggered: {
            listProc.running = false;
            listProc.running = true;
        }
    }

    component DarkFrostOverlay: Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        visible: btRoot.appearanceMode === 2
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
            GradientStop { position: 0.7; color: btRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 1.0; color: btRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
        }
        border.color: btRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: btRoot.glassBorderInner
            border.width: 1
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Item {
            width: parent.width
            height: 32

            Text {
                text: "BLUETOOTH"
                color: btRoot.subTextColor
                font.family: "Inter"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.2
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: refreshMouse.containsMouse ? btRoot.innerHoverColor : "transparent"
                    border.color: btRoot.appearanceMode === 2 ? "transparent" : (refreshMouse.containsMouse ? btRoot.textColor : "transparent")
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰑓"
                        color: refreshMouse.containsMouse ? btRoot.themeAccent : btRoot.textColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            scanProc.running = false;
                            scanProc.running = true;
                        }
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: guiMouse.containsMouse ? btRoot.innerHoverColor : "transparent"
                    border.color: btRoot.appearanceMode === 2 ? "transparent" : (guiMouse.containsMouse ? btRoot.textColor : "transparent")
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰒋"
                        color: guiMouse.containsMouse ? btRoot.themeAccent : btRoot.textColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: guiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            extProc.command = ["bash", "-c", "blueman-manager || kitty --class popup-bt -e bluetuith"]
                            extProc.running = false
                            extProc.running = true
                        }
                    }
                }

                Rectangle {
                    width: 48
                    height: 26
                    radius: 13
                    color: btRoot.isBtOn ? btRoot.themeAccent : btRoot.cardBorderColor
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutExpo } }

                    Rectangle {
                        width: 22
                        height: 22
                        radius: 11
                        y: 2
                        x: btRoot.isBtOn ? 24 : 2
                        color: btRoot.appearanceMode === 0 ? "#11111b" : "#ffffff"
                        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            btRoot.isBtOn = !btRoot.isBtOn
                            if (!btRoot.isBtOn) {
                                btRoot.activeDeviceName = "";
                                btModel.clear();
                            }
                            asyncTask.pendingCmd = (btRoot.isBtOn ? "bluetoothctl power on" : "bluetoothctl power off") + " && sleep 0.5";
                            asyncTask.restart();
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 64
            radius: 12
            color: btRoot.cardBgColor
            border.color: btRoot.activeDeviceName !== "" ? btRoot.themeAccent : btRoot.cardBorderColor
            border.width: btRoot.appearanceMode === 2 ? 0 : 1
            visible: btRoot.activeDeviceName !== "" || btRoot.isBtOn

            DarkFrostOverlay {}

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: btRoot.themeAccent
                border.width: 1
                visible: btRoot.appearanceMode === 2 && btRoot.activeDeviceName !== ""
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 14

                Text {
                    id: mainIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    width: 32
                    text: {
                        if (btRoot.activeDeviceName === "") return "󰂲";
                        if (btRoot.activeDeviceIconType === "audio" || btRoot.activeDeviceIconType === "headset") return "󰋋";
                        if (btRoot.activeDeviceIconType === "controller") return "󰊖";
                        if (btRoot.activeDeviceIconType === "mouse") return "󰍽";
                        if (btRoot.activeDeviceIconType === "keyboard") return "󰌌";
                        if (btRoot.activeDeviceIconType === "phone") return "󰄜";
                        return "󰂯";
                    }
                    color: btRoot.activeDeviceName !== "" ? btRoot.themeAccent : btRoot.subTextColor
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: btRoot.activeDeviceName !== "" ? 22 : 24
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: mainIcon.right
                    anchors.right: mainDisconnect.visible ? mainDisconnect.left : parent.right
                    anchors.rightMargin: 12
                    spacing: 2

                    Text {
                        text: btRoot.activeDeviceName !== "" ? btRoot.activeDeviceName : "Not Connected"
                        color: btRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: btRoot.activeDeviceName !== "" ? "Connected Device" : "No active connection"
                        color: btRoot.activeDeviceName !== "" ? btRoot.themeAccent : btRoot.subTextColor
                        font.family: "Inter"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    id: mainDisconnect
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    width: 78
                    height: 28
                    radius: 6
                    visible: btRoot.activeDeviceName !== ""
                    color: disconnectMouse.containsMouse ? "#f38ba8" : Qt.rgba(243/255, 139/255, 168/255, 0.15)
                    border.color: "#f38ba8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Disconnect"
                        color: disconnectMouse.containsMouse ? (btRoot.appearanceMode === 0 ? "#11111b" : "#ffffff") : "#f38ba8"
                        font.family: "Inter"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        id: disconnectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var dMac = btRoot.activeDeviceMac;
                            btRoot.activeDeviceName = ""; 
                            asyncTask.pendingCmd = "bluetoothctl disconnect " + dMac;
                            asyncTask.restart();
                        }
                    }
                }
            }
        }

        Text {
            text: "AVAILABLE DEVICES"
            color: btRoot.subTextColor
            font.family: "Inter"
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1.1
            visible: !btRoot.isInitialFetch && (btRoot.isBtOn || btModel.count > 0)
        }

        ListView {
            id: btListView
            width: parent.width
            height: parent.height - 150
            spacing: 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: btModel
            visible: !btRoot.isInitialFetch && (btRoot.isBtOn || btModel.count > 0)

            delegate: Rectangle {
                id: delegateRect
                width: btListView.width
                height: 50
                radius: 10
                
                property bool isConnected: model.connected === true
                property string itemName: model.name !== undefined ? model.name : ""
                property string itemMac: model.mac !== undefined ? model.mac : ""
                property string itemIconType: model.iconType !== undefined ? model.iconType : "default"

                color: btRoot.appearanceMode === 2 ? "transparent" : ((netMouse.containsMouse || btnMouse.containsMouse) ? btRoot.innerHoverColor : btRoot.innerBgColor)
                border.color: btRoot.appearanceMode === 2 ? "transparent" : (isConnected ? btRoot.themeAccent : btRoot.cardBorderColor)
                border.width: 1

                DarkFrostOverlay { anchors.fill: parent; radius: 10; visible: btRoot.appearanceMode === 2 }

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: btRoot.themeAccent
                    border.width: 1
                    visible: btRoot.appearanceMode === 2 && (isConnected || netMouse.containsMouse || btnMouse.containsMouse)
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12

                    Text {
                        id: devIcon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: 28
                        text: {
                            if (delegateRect.itemIconType === "audio" || delegateRect.itemIconType === "headset") return "󰋋";
                            if (delegateRect.itemIconType === "controller") return "󰊖";
                            if (delegateRect.itemIconType === "mouse") return "󰍽";
                            if (delegateRect.itemIconType === "keyboard") return "󰌌";
                            if (delegateRect.itemIconType === "phone") return "󰄜";
                            return "󰂯";
                        }
                        color: delegateRect.isConnected ? btRoot.themeAccent : btRoot.textColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                    }

                    Text {
                        id: devName
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: devIcon.right
                        anchors.right: connectBtn.left
                        anchors.rightMargin: 6
                        text: delegateRect.itemName
                        color: delegateRect.isConnected ? btRoot.themeAccent : btRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.bold: delegateRect.isConnected
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        id: connectBtn
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        width: 74
                        height: 28
                        radius: 6
                        
                        opacity: (delegateRect.isConnected || netMouse.containsMouse || btnMouse.containsMouse || btRoot.connectingMac === delegateRect.itemMac) ? 1 : 0
                        visible: opacity > 0
                        
                        color: delegateRect.isConnected ? (btnMouse.containsMouse ? "#f38ba8" : Qt.rgba(243/255, 139/255, 168/255, 0.15)) : (btnMouse.containsMouse ? btRoot.themeAccent : btRoot.cardBgColor)
                        border.color: delegateRect.isConnected ? "#f38ba8" : btRoot.themeAccent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: delegateRect.isConnected ? "Disconnect" : (btRoot.connectingMac === delegateRect.itemMac ? "..." : "Connect")
                            color: delegateRect.isConnected ? (btnMouse.containsMouse ? (btRoot.appearanceMode === 0 ? "#11111b" : "#ffffff") : "#f38ba8") : (btnMouse.containsMouse ? (btRoot.appearanceMode === 0 ? "#11111b" : "#ffffff") : btRoot.textColor)
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                btRoot.connectingMac = delegateRect.itemMac;
                                if (delegateRect.isConnected) {
                                    asyncTask.pendingCmd = "bluetoothctl disconnect " + delegateRect.itemMac;
                                } else {
                                    asyncTask.pendingCmd = "bluetoothctl connect " + delegateRect.itemMac;
                                }
                                asyncTask.restart();
                            }
                        }
                    }
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    z: -1
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !btRoot.isBtOn && !btRoot.isInitialFetch && btModel.count === 0
        text: "Bluetooth is turned off"
        color: btRoot.subTextColor
        font.family: "Inter"
        font.pixelSize: 13
    }

    Process {
        id: powerProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'on' || echo 'off'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text ? this.text.trim() : "";
                btRoot.isBtOn = (out === "on");
                listProc.running = false;
                listProc.running = true;
            }
        }
    }

    Process {
        id: scanProc
        command: ["bash", "-c", "bluetoothctl scan on & sleep 2 && bluetoothctl scan off"]
        onExited: {
            powerProc.running = false;
            powerProc.running = true;
        }
    }

    Process {
        id: listProc
        command: ["bash", "-c", "bluetoothctl devices | while read -r type mac name; do info=$(bluetoothctl info \"$mac\"); conn=$(echo \"$info\" | grep -q 'Connected: yes' && echo 'yes' || echo 'no'); icon=$(echo \"$info\" | grep 'Icon:' | awk '{print $2}'); echo \"$mac|$name|$conn|$icon\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                btRoot.isInitialFetch = false;
                var out = this.text ? this.text.trim() : "";
                
                if (out === "" || !btRoot.isBtOn) {
                    btRoot.activeDeviceName = "";
                    btRoot.activeDeviceMac = "";
                    btModel.clear();
                    return;
                }

                var lines = out.split("\n");
                var newItems = [];
                var foundActiveName = "";
                var foundActiveMac = "";
                var foundActiveIcon = "default";

                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].trim() === "") continue;
                    var p = lines[i].split("|");
                    if (p.length < 4) continue;

                    var mac = p[0];
                    var name = p[1];
                    var connected = (p[2] === "yes");
                    var rawIcon = p[3].toLowerCase();

                    var iconType = "default";
                    if (rawIcon.indexOf("audio") !== -1 || rawIcon.indexOf("headset") !== -1 || rawIcon.indexOf("headphone") !== -1) {
                        iconType = "audio";
                    } else if (rawIcon.indexOf("input-gaming") !== -1 || rawIcon.indexOf("joystick") !== -1 || rawIcon.indexOf("controller") !== -1) {
                        iconType = "controller";
                    } else if (rawIcon.indexOf("input-mouse") !== -1 || rawIcon.indexOf("mouse") !== -1) {
                        iconType = "mouse";
                    } else if (rawIcon.indexOf("input-keyboard") !== -1 || rawIcon.indexOf("keyboard") !== -1) {
                        iconType = "keyboard";
                    } else if (rawIcon.indexOf("phone") !== -1 || rawIcon.indexOf("smartphone") !== -1) {
                        iconType = "phone";
                    }

                    if (connected && foundActiveName === "") {
                        foundActiveName = name;
                        foundActiveMac = mac;
                        foundActiveIcon = iconType;
                    }

                    newItems.push({
                        "mac": mac,
                        "name": name,
                        "connected": connected,
                        "iconType": iconType
                    });
                }
                
                btRoot.activeDeviceName = foundActiveName;
                btRoot.activeDeviceMac = foundActiveMac;
                btRoot.activeDeviceIconType = foundActiveIcon;

                var targetCount = newItems.length;
                for (var j = 0; j < targetCount; j++) {
                    if (j < btModel.count) {
                        var cur = btModel.get(j);
                        if (cur.mac !== newItems[j].mac) btModel.setProperty(j, "mac", newItems[j].mac);
                        if (cur.name !== newItems[j].name) btModel.setProperty(j, "name", newItems[j].name);
                        if (cur.connected !== newItems[j].connected) btModel.setProperty(j, "connected", newItems[j].connected);
                        if (cur.iconType !== newItems[j].iconType) btModel.setProperty(j, "iconType", newItems[j].iconType);
                    } else {
                        btModel.append(newItems[j]);
                    }
                }
                while (btModel.count > targetCount) {
                    btModel.remove(btModel.count - 1);
                }
            }
        }
    }

    Process { 
        id: actionProc 
        stdout: StdioCollector {
            onStreamFinished: {
                btRoot.connectingMac = "";
                powerProc.running = false;
                powerProc.running = true;
                delayedRefreshTimer.restart();
            }
        }
    }

    Process { id: extProc }

    Timer {
        interval: 6000
        running: btRoot.visible
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            if (btRoot.isBtOn) {
                listProc.running = false;
                listProc.running = true;
            }
        }
    }

    Component.onCompleted: {
        powerProc.running = false;
        powerProc.running = true;
    }
}