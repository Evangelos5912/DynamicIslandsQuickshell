import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: wifiRoot

    width: parent.width
    height: parent.height

    property var rootRef: parent.parent !== undefined ? parent.parent : null
    
    property string themeAccent: rootRef ? rootRef.themeAccent : "#89b4fa"
    property int appearanceMode: rootRef ? rootRef.appearanceMode : 0 
    property bool isWallpaperLight: rootRef ? rootRef.isWallpaperLight : false
    
    property color glassBorderInner: rootRef ? rootRef.glassBorderInner : Qt.rgba(1, 1, 1, 0.3)
    property color glassBgColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05)
    property color glassBorderColor: isWallpaperLight ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.15)
    property color glassInnerBg: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(0, 0, 0, 0.15)
    property color glassHoverColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.1)
    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassSubTextColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(1, 1, 1, 0.7)

    property color cardBgColor: appearanceMode === 0 ? "#181825" : (appearanceMode === 1 ? "#e8e8ed" : glassBgColor)
    property color cardBorderColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassBorderColor)
    property color innerBgColor: appearanceMode === 0 ? "#11111b" : (appearanceMode === 1 ? "#ffffff" : glassInnerBg)
    property color innerHoverColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassHoverColor)
    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color subTextColor: appearanceMode === 0 ? "#6c7086" : (appearanceMode === 1 ? "#86868b" : glassSubTextColor)

    property bool isWifiOn: true
    property bool isInitialFetch: true
    
    property string activeBaseSsid: ""
    property int activeBaseSignal: 0
    property string activeBaseType: "wifi" 
    property string activeBaseUuid: ""
    
    property string connectingSsid: ""
    property string connectingType: ""

    ListModel {
        id: wifiModel
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
        visible: wifiRoot.appearanceMode === 2
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
            GradientStop { position: 0.7; color: wifiRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 1.0; color: wifiRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
        }
        border.color: wifiRoot.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: wifiRoot.glassBorderInner
            border.width: 1
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Row {
            width: parent.width
            height: 32
            spacing: 10

            Text {
                text: "NETWORKS"
                color: wifiRoot.subTextColor
                font.family: "Inter"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.2
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width - 220
                height: 1
            }

            Rectangle {
                width: 32
                height: 32
                radius: 8
                color: refreshMouse.containsMouse ? wifiRoot.innerHoverColor : "transparent"
                border.color: wifiRoot.appearanceMode === 2 ? "transparent" : (refreshMouse.containsMouse ? wifiRoot.themeAccent : "transparent")
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰑓"
                    color: refreshMouse.containsMouse ? wifiRoot.themeAccent : wifiRoot.textColor
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
                        listProc.running = false;
                        listProc.running = true;
                    }
                }
            }

            Rectangle {
                width: 32
                height: 32
                radius: 8
                color: guiMouse.containsMouse ? wifiRoot.innerHoverColor : "transparent"
                border.color: wifiRoot.appearanceMode === 2 ? "transparent" : (guiMouse.containsMouse ? wifiRoot.themeAccent : "transparent")
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒋"
                    color: guiMouse.containsMouse ? wifiRoot.themeAccent : wifiRoot.textColor
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
                        extProc.command = ["bash", "-c", "kitty --class popup-net -e nmtui"]
                        extProc.running = false
                        extProc.running = true
                    }
                }
            }

            Rectangle {
                width: 48
                height: 26
                radius: 13
                color: wifiRoot.isWifiOn ? wifiRoot.themeAccent : wifiRoot.cardBorderColor
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutExpo } }

                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    y: 2
                    x: wifiRoot.isWifiOn ? 24 : 2
                    color: wifiRoot.appearanceMode === 0 ? "#11111b" : "#ffffff"
                    Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        wifiRoot.isWifiOn = !wifiRoot.isWifiOn
                        if (!wifiRoot.isWifiOn && wifiRoot.activeBaseType === "wifi") {
                            wifiRoot.activeBaseSsid = "";
                        }
                        asyncTask.pendingCmd = wifiRoot.isWifiOn ? "nmcli radio wifi on" : "nmcli radio wifi off";
                        asyncTask.restart();
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 64
            radius: 12
            color: wifiRoot.cardBgColor
            border.color: wifiRoot.activeBaseSsid !== "" ? wifiRoot.themeAccent : wifiRoot.cardBorderColor
            border.width: wifiRoot.appearanceMode === 2 ? 0 : 1
            visible: wifiRoot.activeBaseSsid !== "" || wifiRoot.isWifiOn

            DarkFrostOverlay {}

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: wifiRoot.themeAccent
                border.width: 1
                visible: wifiRoot.appearanceMode === 2 && wifiRoot.activeBaseSsid !== ""
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
                    text: wifiRoot.activeBaseSsid !== "" ? (wifiRoot.activeBaseType === "eth" ? "󰈀" : (wifiRoot.activeBaseSignal > 80 ? "󰤨" : (wifiRoot.activeBaseSignal > 60 ? "󰤥" : (wifiRoot.activeBaseSignal > 40 ? "󰤢" : (wifiRoot.activeBaseSignal > 20 ? "󰤟" : "󰤯"))))) : "󰤭"
                    color: wifiRoot.activeBaseSsid !== "" ? wifiRoot.themeAccent : wifiRoot.subTextColor
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: wifiRoot.activeBaseType === "wifi" ? 22 : 24
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: mainIcon.right
                    anchors.right: mainDisconnect.visible ? mainDisconnect.left : parent.right
                    anchors.rightMargin: 12
                    spacing: 2

                    Text {
                        text: wifiRoot.activeBaseSsid !== "" ? wifiRoot.activeBaseSsid : "Not Connected"
                        color: wifiRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: wifiRoot.activeBaseSsid !== "" ? "Primary Network" : "No active connection"
                        color: wifiRoot.activeBaseSsid !== "" ? wifiRoot.themeAccent : wifiRoot.subTextColor
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
                    visible: wifiRoot.activeBaseSsid !== ""
                    color: disconnectMouse.containsMouse ? "#f38ba8" : Qt.rgba(243/255, 139/255, 168/255, 0.15)
                    border.color: "#f38ba8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Disconnect"
                        color: disconnectMouse.containsMouse ? (wifiRoot.appearanceMode === 0 ? "#11111b" : "#ffffff") : "#f38ba8"
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
                            var uType = wifiRoot.activeBaseType;
                            wifiRoot.activeBaseSsid = "";
                            
                            if (uType === "wifi") {
                                asyncTask.pendingCmd = "DEV=$(LC_ALL=C nmcli -t -f DEVICE,TYPE d | awk -F: '$2==\"wifi\"{print $1}' | head -n1); if [ -n \"$DEV\" ]; then nmcli dev disconnect \"$DEV\"; fi 2>&1";
                            } else if (uType === "eth") {
                                asyncTask.pendingCmd = "DEV=$(LC_ALL=C nmcli -t -f DEVICE,TYPE d | awk -F: '$2==\"ethernet\"{print $1}' | head -n1); if [ -n \"$DEV\" ]; then nmcli dev disconnect \"$DEV\"; fi 2>&1";
                            }
                            asyncTask.restart();
                        }
                    }
                }
            }
        }

        Text {
            text: "AVAILABLE"
            color: wifiRoot.subTextColor
            font.family: "Inter"
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1.1
            visible: !wifiRoot.isInitialFetch && (wifiRoot.isWifiOn || wifiModel.count > 0)
        }

        ListView {
            id: wifiListView
            width: parent.width
            height: parent.height - 150
            spacing: 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: wifiModel
            visible: !wifiRoot.isInitialFetch && (wifiRoot.isWifiOn || wifiModel.count > 0)

            delegate: Rectangle {
                id: delegateRect
                width: wifiListView.width
                height: 50
                radius: 10
                
                property bool isCurrentActive: model.active !== undefined ? model.active : false
                property string itemSsid: model.ssid !== undefined ? model.ssid : ""
                property int itemSignal: model.signal !== undefined ? model.signal : 0
                property bool isSecured: model.secured !== undefined ? model.secured : true
                property bool isEth: model.isEth !== undefined ? model.isEth : false
                property bool isVpn: model.isVpn !== undefined ? model.isVpn : false
                property string itemUuid: model.uuid !== undefined ? model.uuid : ""
                property bool isSaved: itemUuid !== ""

                color: wifiRoot.appearanceMode === 2 ? "transparent" : ((netMouse.containsMouse || btnMouse.containsMouse) ? wifiRoot.innerHoverColor : wifiRoot.innerBgColor)
                border.color: wifiRoot.appearanceMode === 2 ? "transparent" : (isCurrentActive ? wifiRoot.themeAccent : wifiRoot.cardBorderColor)
                border.width: 1

                DarkFrostOverlay { anchors.fill: parent; radius: 10; visible: wifiRoot.appearanceMode === 2 }

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: wifiRoot.themeAccent
                    border.width: 1
                    visible: wifiRoot.appearanceMode === 2 && (delegateRect.isCurrentActive || netMouse.containsMouse || btnMouse.containsMouse)
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12

                    Text {
                        id: netIcon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: 24
                        text: delegateRect.isEth ? "󰈀" : (delegateRect.isVpn ? "󰦝" : (delegateRect.itemSignal > 80 ? "󰤨" : (delegateRect.itemSignal > 60 ? "󰤥" : (delegateRect.itemSignal > 40 ? "󰤢" : (delegateRect.itemSignal > 20 ? "󰤟" : "󰤯")))))
                        color: delegateRect.isCurrentActive ? wifiRoot.themeAccent : wifiRoot.textColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: delegateRect.isEth || delegateRect.isVpn ? 18 : 16
                    }

                    Text {
                        id: netName
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: netIcon.right
                        anchors.right: lockIcon.visible ? lockIcon.left : (connectBtn.opacity > 0 || delegateRect.isCurrentActive ? connectBtn.left : parent.right)
                        anchors.rightMargin: 6
                        text: delegateRect.itemSsid
                        color: delegateRect.isCurrentActive ? wifiRoot.themeAccent : wifiRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.bold: delegateRect.isCurrentActive
                        elide: Text.ElideRight
                    }

                    Text {
                        id: lockIcon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: connectBtn.opacity > 0 || delegateRect.isCurrentActive ? connectBtn.left : parent.right
                        anchors.rightMargin: 6
                        visible: delegateRect.isSecured && !delegateRect.isEth && !delegateRect.isVpn
                        text: "󰌾"
                        color: wifiRoot.subTextColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    Rectangle {
                        id: connectBtn
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        width: 74
                        height: 28
                        radius: 6
                        

                        opacity: (delegateRect.isCurrentActive || netMouse.containsMouse || btnMouse.containsMouse || wifiRoot.connectingSsid === delegateRect.itemSsid) ? 1 : 0
                        visible: opacity > 0
                        
                        color: delegateRect.isCurrentActive ? (btnMouse.containsMouse ? "#f38ba8" : Qt.rgba(243/255, 139/255, 168/255, 0.15)) : (btnMouse.containsMouse ? wifiRoot.themeAccent : wifiRoot.cardBgColor)
                        border.color: delegateRect.isCurrentActive ? "#f38ba8" : wifiRoot.themeAccent
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: delegateRect.isCurrentActive ? "Disconnect" : (wifiRoot.connectingSsid === delegateRect.itemSsid ? "..." : "Connect")
                            color: delegateRect.isCurrentActive ? (btnMouse.containsMouse ? (wifiRoot.appearanceMode === 0 ? "#11111b" : "#ffffff") : "#f38ba8") : (btnMouse.containsMouse ? (wifiRoot.appearanceMode === 0 ? "#11111b" : "#ffffff") : wifiRoot.textColor)
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
                                if (delegateRect.isCurrentActive) {
                                    var downUuid = delegateRect.itemUuid;
                                    if (delegateRect.isEth) {
                                        asyncTask.pendingCmd = "DEV=$(LC_ALL=C nmcli -t -f DEVICE,TYPE d | awk -F: '$2==\"ethernet\"{print $1}' | head -n1); if [ -n \"$DEV\" ]; then nmcli dev disconnect \"$DEV\"; fi 2>&1";
                                    } else if (delegateRect.isVpn) {
                                        asyncTask.pendingCmd = "nmcli connection down uuid '" + downUuid + "' 2>&1";
                                    } else {
                                        asyncTask.pendingCmd = "DEV=$(LC_ALL=C nmcli -t -f DEVICE,TYPE d | awk -F: '$2==\"wifi\"{print $1}' | head -n1); if [ -n \"$DEV\" ]; then nmcli dev disconnect \"$DEV\"; fi 2>&1";
                                    }
                                    asyncTask.restart();
                                } else {
                                    wifiRoot.connectingSsid = delegateRect.itemSsid;
                                    wifiRoot.connectingType = delegateRect.isVpn ? "vpn" : (delegateRect.isEth ? "eth" : "wifi");
                                    
                                    if (delegateRect.isSaved || delegateRect.isEth || delegateRect.isVpn || !delegateRect.isSecured) {
                                        var safeUuid = delegateRect.itemUuid;
                                        var safeSsid = delegateRect.itemSsid.replace(/'/g, "'\\''");
                                        
                                        if (safeUuid !== "") {
                                            asyncTask.pendingCmd = "nmcli connection up uuid '" + safeUuid + "' 2>&1";
                                        } else {
                                            asyncTask.pendingCmd = "nmcli dev wifi connect '" + safeSsid + "' 2>&1";
                                        }
                                        asyncTask.restart();
                                    } else {
                                        passOverlay.targetSsid = delegateRect.itemSsid;
                                        passInput.text = "";
                                        passInput.forceActiveFocus();
                                    }
                                }
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
        visible: !wifiRoot.isWifiOn && !wifiRoot.isInitialFetch && wifiModel.count === 0
        text: "Wi-Fi is turned off"
        color: wifiRoot.subTextColor
        font.family: "Inter"
        font.pixelSize: 13
    }


    Rectangle {
        id: passOverlay
        width: parent.width
        height: parent.height
        radius: 18
        color: wifiRoot.cardBgColor
        border.color: wifiRoot.cardBorderColor
        border.width: 1
        clip: true
        z: 999

        property string targetSsid: ""
        property bool isConnecting: false
        property string errorMessage: ""
        
        x: targetSsid !== "" ? 0 : parent.width
        Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

        DarkFrostOverlay {}

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true 
            onClicked: {} 
        }

        Column {
            anchors.centerIn: parent
            width: parent.width - 48
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "󰌾"
                color: wifiRoot.themeAccent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 42
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Authentication Required"
                    color: wifiRoot.textColor
                    font.family: "Inter"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Enter password for \"" + passOverlay.targetSsid + "\""
                    color: wifiRoot.subTextColor
                    font.family: "Inter"
                    font.pixelSize: 12
                    elide: Text.ElideMiddle
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: wifiRoot.innerBgColor
                border.color: passInput.activeFocus ? wifiRoot.themeAccent : wifiRoot.cardBorderColor
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    TextInput {
                        id: passInput
                        width: parent.width - 28
                        height: parent.height
                        verticalAlignment: TextInput.AlignVCenter
                        color: wifiRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 14
                        echoMode: showPassCheck.showPass ? TextInput.Normal : TextInput.Password
                        clip: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Password"
                            color: wifiRoot.subTextColor
                            font.family: "Inter"
                            font.pixelSize: 14
                            visible: !parent.text && !parent.activeFocus
                        }

                        Keys.onReturnPressed: {
                            if (passInput.text.trim() === "") return;
                            passOverlay.isConnecting = true;
                            passOverlay.errorMessage = "";
                            var safeSsid = passOverlay.targetSsid.replace(/'/g, "'\\''");
                            var safePass = passInput.text.replace(/'/g, "'\\''");
                            passConnectProc.command = ["bash", "-c", "nmcli dev wifi connect '" + safeSsid + "' password '" + safePass + "' 2>&1"];
                            passConnectProc.running = false;
                            passConnectProc.running = true;
                        }
                    }

                    Text {
                        id: showPassCheck
                        property bool showPass: false
                        anchors.verticalCenter: parent.verticalCenter
                        text: showPass ? "󰈈" : "󰈉"
                        color: showPassMouse.containsMouse ? wifiRoot.themeAccent : wifiRoot.subTextColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15

                        MouseArea {
                            id: showPassMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showPassCheck.showPass = !showPassCheck.showPass
                        }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: passOverlay.errorMessage !== ""
                text: passOverlay.errorMessage
                color: "#f38ba8"
                font.family: "Inter"
                font.pixelSize: 12
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Rectangle {
                    width: 120
                    height: 38
                    radius: 8
                    color: cancelMouse.containsMouse ? wifiRoot.innerHoverColor : "transparent"
                    border.color: wifiRoot.cardBorderColor
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: wifiRoot.textColor
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passOverlay.targetSsid = ""
                            wifiRoot.connectingSsid = ""
                        }
                    }
                }

                Rectangle {
                    width: 120
                    height: 38
                    radius: 8
                    color: passOverlay.isConnecting ? wifiRoot.subTextColor : wifiRoot.themeAccent

                    Text {
                        anchors.centerIn: parent
                        text: passOverlay.isConnecting ? "Connecting..." : "Connect"
                        color: wifiRoot.appearanceMode === 0 ? "#11111b" : "#ffffff"
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        id: connectBtnMouse
                        anchors.fill: parent
                        cursorShape: passOverlay.isConnecting ? Qt.ArrowCursor : Qt.PointingHandCursor
                        enabled: !passOverlay.isConnecting
                        onClicked: {
                            if (passInput.text.trim() === "") return;
                            passOverlay.isConnecting = true;
                            passOverlay.errorMessage = "";
                            var safeSsid = passOverlay.targetSsid.replace(/'/g, "'\\''");
                            var safePass = passInput.text.replace(/'/g, "'\\''");
                            passConnectProc.command = ["bash", "-c", "nmcli dev wifi connect '" + safeSsid + "' password '" + safePass + "' 2>&1"];
                            passConnectProc.running = false;
                            passConnectProc.running = true;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: passConnectProc
        stdout: StdioCollector {
            onStreamFinished: {
                passOverlay.isConnecting = false;
                var out = this.text ? this.text.trim() : "";
                if (out.indexOf("successfully") !== -1 || out.indexOf("Device") !== -1 || out.indexOf("success") !== -1) {
                    passOverlay.targetSsid = ""; 
                    wifiRoot.connectingSsid = "";
                    listProc.running = false;
                    listProc.running = true;
                } else if (out !== "") {
                    passOverlay.errorMessage = "Failed to connect. Check password.";
                }
            }
        }
    }


    Process {
        id: radioProc
        command: ["bash", "-c", "LC_ALL=C nmcli radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text ? this.text.trim() : "";
                wifiRoot.isWifiOn = (out === "enabled");
                listProc.running = false;
                listProc.running = true;
            }
        }
    }

    Process {
        id: scanProc
        command: ["bash", "-c", "nmcli dev wifi rescan"]
        onExited: {
            radioProc.running = false;
            radioProc.running = true;
        }
    }

    Process {
        id: listProc
        command: ["bash", "-c", "LC_ALL=C nmcli -t -e yes -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list 2>/dev/null; echo '---SAVED---'; LC_ALL=C nmcli -t -f NAME,TYPE,DEVICE,UUID,STATE connection show"]
        stdout: StdioCollector {
            onStreamFinished: {
                wifiRoot.isInitialFetch = false;
                var out = this.text ? this.text.trim() : "";
                if (out === "") return;

                var chunks = out.split("---SAVED---");
                var wifiLines = (wifiRoot.isWifiOn && chunks[0]) ? chunks[0].trim().split("\n") : [];
                var connLines = chunks[1] ? chunks[1].trim().split("\n") : [];

                var savedMap = {}; 
                var newItems = [];
                var foundActiveBaseSsid = "";
                var foundActiveBaseSignal = 0;
                var foundActiveBaseType = "wifi";
                var foundActiveBaseUuid = "";

                for (var s = 0; s < connLines.length; s++) {
                    var cl = connLines[s].trim();
                    if (cl === "") continue;
                    var parts = cl.replace(/\\:/g, "%%COLON%%").split(":");
                    if (parts.length >= 4) {
                        var cName = parts[0].replace(/%%COLON%%/g, ":");
                        var cType = parts[1];
                        var cDevice = parts[2].trim();
                        var cUuid = parts[3].trim();
                        var cActive = (cDevice !== "" && cDevice !== "--"); 

                        if (cType.indexOf("wireless") !== -1 || cType.indexOf("wifi") !== -1) {
                            savedMap[cName] = cUuid;
                        } else if (cType.indexOf("ethernet") !== -1 || cType.indexOf("wireguard") !== -1 || cType.indexOf("vpn") !== -1 || cType.indexOf("tun") !== -1) {
                            var isEth = cType.indexOf("ethernet") !== -1;
                            newItems.push({
                                "ssid": cName, "signal": 100, "active": cActive, 
                                "secured": true, "isVpn": !isEth, "isEth": isEth, "uuid": cUuid
                            });
                            
                            if (cActive && isEth) { 
                                foundActiveBaseSsid = cName; 
                                foundActiveBaseSignal = 100; 
                                foundActiveBaseType = "eth"; 
                                foundActiveBaseUuid = cUuid;
                            }
                        }
                    }
                }

                if (wifiRoot.isWifiOn) {
                    var uniqueSSIDs = {};
                    for (var i = 0; i < wifiLines.length; i++) {
                        if (wifiLines[i] === "") continue;
                        var p = wifiLines[i].replace(/\\:/g, "%%COLON%%").split(":");
                        if (p.length < 4) continue;

                        var active = (p[0] === "*");
                        var sig = parseInt(p[1]) || 0;
                        var sec = p[2] ? p[2].replace(/%%COLON%%/g, ":").toUpperCase() : "";
                        var ssid = p.slice(3).join(":").replace(/%%COLON%%/g, ":");
                        var isSec = (sec.trim() !== "" && sec.trim() !== "--");
                        var wUuid = savedMap[ssid] !== undefined ? savedMap[ssid] : "";

                        if (active && ssid !== "" && foundActiveBaseType !== "eth") {
                            foundActiveBaseSsid = ssid;
                            foundActiveBaseSignal = sig;
                            foundActiveBaseType = "wifi";
                            foundActiveBaseUuid = wUuid;
                        }

                        if (ssid !== "" && !uniqueSSIDs[ssid]) {
                            uniqueSSIDs[ssid] = true;
                            newItems.push({
                                "ssid": ssid, "signal": sig, "active": active, 
                                "secured": isSec, "isVpn": false, "isEth": false, "uuid": wUuid
                            });
                        }
                    }
                }

                wifiRoot.activeBaseSsid = foundActiveBaseSsid;
                wifiRoot.activeBaseSignal = foundActiveBaseSignal;
                wifiRoot.activeBaseType = foundActiveBaseType;
                wifiRoot.activeBaseUuid = foundActiveBaseUuid;

                var targetCount = newItems.length;
                for (var j = 0; j < targetCount; j++) {
                    if (j < wifiModel.count) {
                        var cur = wifiModel.get(j);
                        if (cur.ssid !== newItems[j].ssid) wifiModel.setProperty(j, "ssid", newItems[j].ssid);
                        if (cur.signal !== newItems[j].signal) wifiModel.setProperty(j, "signal", newItems[j].signal);
                        if (cur.active !== newItems[j].active) wifiModel.setProperty(j, "active", newItems[j].active);
                        if (cur.secured !== newItems[j].secured) wifiModel.setProperty(j, "secured", newItems[j].secured);
                        if (cur.isEth !== newItems[j].isEth) wifiModel.setProperty(j, "isEth", newItems[j].isEth);
                        if (cur.isVpn !== newItems[j].isVpn) wifiModel.setProperty(j, "isVpn", newItems[j].isVpn);
                        if (cur.uuid !== newItems[j].uuid) wifiModel.setProperty(j, "uuid", newItems[j].uuid);
                    } else {
                        wifiModel.append(newItems[j]);
                    }
                }
                while (wifiModel.count > targetCount) {
                    wifiModel.remove(wifiModel.count - 1);
                }
            }
        }
    }

    Process { 
        id: actionProc 
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text ? this.text.trim() : "";
                
                if (wifiRoot.connectingSsid !== "" && wifiRoot.connectingType === "wifi" && (out.toLowerCase().indexOf("error") !== -1 || out.toLowerCase().indexOf("fail") !== -1)) {
                    passOverlay.targetSsid = wifiRoot.connectingSsid;
                    passInput.text = "";
                    passInput.forceActiveFocus();
                }
                
                wifiRoot.connectingSsid = "";
                wifiRoot.connectingType = "";
                
                listProc.running = false;
                listProc.running = true;
                delayedRefreshTimer.restart();
            }
        }
    }

    Process { id: extProc }

    Timer {
        id: scanTimer
        interval: 350
        repeat: false
        onTriggered: {
            scanProc.running = false;
            scanProc.running = true;
        }
    }

    Timer {
        interval: 10000
        running: wifiRoot.visible && passOverlay.targetSsid === ""
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            radioProc.running = false;
            radioProc.running = true;
        }
    }

    Component.onCompleted: {
        radioProc.running = false;
        radioProc.running = true;
    }
}