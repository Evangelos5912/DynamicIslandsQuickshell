import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root
    property bool expanded: false
    property string activeSubView: ""

    property string themeAccent: "#89b4fa"
    property int appearanceMode: 0 
    property int layoutStyle: 0
    property bool isWallpaperLight: false
    
    property color glassBgColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.08)
    property color glassHoverColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.1)
    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassTrackColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(0, 0, 0, 0.3)
    
    property color glassBorderOuter: isWallpaperLight ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.15)
    property color glassBorderInner: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.3)
    
    property color bgColor: appearanceMode === 0 ? "#1a1b26" : (appearanceMode === 1 ? "#f5f5f7" : glassBgColor)
    property color btnColor: appearanceMode === 0 ? "#181825" : (appearanceMode === 1 ? "#e8e8ed" : "transparent")
    property color btnHoverColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassHoverColor)
    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color trackColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#e8e8ed" : glassTrackColor)

    property string connectionType: "none"
    property string wifiName: "Disconnected"
    property int wifiSignal: 0
    property string btName: "Disconnected"
    property int volLevel: 50
    property int briLevel: 100
    property string powerProfile: "balanced"
    
    property bool volDragging: false
    property bool briDragging: false

    property string networkIcon: connectionType === "eth" ? "󰈀" : (connectionType === "wifi" ? (wifiSignal > 80 ? "󰤨" : (wifiSignal > 60 ? "󰤥" : (wifiSignal > 40 ? "󰤢" : (wifiSignal > 20 ? "󰤟" : "󰤯")))) : "󰤭")

    implicitWidth: expanded ? (activeSubView !== "" ? 260 + 16 + 400 : 260) : 36
    implicitHeight: expanded ? (activeSubView !== "" ? 800 : 410) : 36 
    
    Behavior on implicitWidth { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
    Behavior on implicitHeight { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

    onExpandedChanged: {
        if (!expanded) {
            activeSubView = "";
        }
    }

    HoverHandler { id: rootHover }

    property string _focusTracker: (Hyprland.focusedClient ? Hyprland.focusedClient.address : "null") + "_" + (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "null")
    on_FocusTrackerChanged: {
        if (root.expanded && !rootHover.hovered) {
            root.expanded = false;
            root.activeSubView = "";
        }
    }

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///home/" + Quickshell.env("USER") + "/.config/quickshell/island_appearance?t=" + new Date().getTime());
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.responseText) {
                var val = parseInt(xhr.responseText.trim());
                if (!isNaN(val) && (val === 0 || val === 1 || val === 2)) {
                    root.appearanceMode = val;
                }
            }
        }
        xhr.send();

        var layoutXhr = new XMLHttpRequest();
        layoutXhr.open("GET", "file:///home/" + Quickshell.env("USER") + "/.config/quickshell/island_layout?t=" + new Date().getTime());
        layoutXhr.onreadystatechange = function() {
            if (layoutXhr.readyState === XMLHttpRequest.DONE && layoutXhr.responseText) {
                var lVal = parseInt(layoutXhr.responseText.trim());
                if (!isNaN(lVal) && (lVal === 0 || lVal === 1)) {
                    root.layoutStyle = lVal;
                }
            }
        }
        layoutXhr.send();
    }

    component GlassOverlay: Item {
        property var targetNode
        anchors.fill: parent
        visible: root.appearanceMode === 2
        
        Rectangle {
            anchors.fill: parent
            topLeftRadius: targetNode.topLeftRadius
            topRightRadius: targetNode.topRightRadius
            bottomLeftRadius: targetNode.bottomLeftRadius
            bottomRightRadius: targetNode.bottomRightRadius
            color: "transparent"
            border.color: root.glassBorderOuter
            border.width: 1
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1 
            topLeftRadius: targetNode.topLeftRadius > 0 ? targetNode.topLeftRadius - 1 : 0
            topRightRadius: targetNode.topRightRadius > 0 ? targetNode.topRightRadius - 1 : 0
            bottomLeftRadius: targetNode.bottomLeftRadius - 1
            bottomRightRadius: targetNode.bottomRightRadius - 1
            color: "transparent"
            border.color: root.glassBorderInner
            border.width: 1
        }
    }

    Rectangle {
        id: mainIsland
        width: root.expanded ? 260 : 36
        height: root.expanded ? 410 : 36
        
        topLeftRadius: root.layoutStyle === 1 ? 0 : 18
        topRightRadius: root.layoutStyle === 1 ? 0 : 18
        bottomLeftRadius: 18
        bottomRightRadius: 18

        color: root.bgColor
        border.color: root.appearanceMode === 2 ? "transparent" : root.themeAccent
        border.width: 1
        clip: true

        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        GlassOverlay { targetNode: mainIsland }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: {
                root.expanded = false;
                root.activeSubView = "";
            }
        }

        Item {
            anchors.fill: parent
            opacity: root.expanded ? 0 : 1
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            
            Text {
                anchors.centerIn: parent
                text: root.networkIcon
                color: root.themeAccent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
            }

            MouseArea {
                anchors.fill: parent
                enabled: !root.expanded
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.expanded = true;
                    writeNet.running = true;
                    fetchBtName.running = true;
                    fetchVol.running = true;
                    fetchBri.running = true;
                    fetchProfile.running = true;
                }
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            opacity: root.expanded ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Rectangle {
                width: parent.width
                height: 42
                radius: 12
                color: wifiMouseArea.containsMouse || root.activeSubView === "wifi" ? root.btnHoverColor : root.btnColor
                border.color: root.appearanceMode === 2 ? "transparent" : (wifiMouseArea.containsMouse || root.activeSubView === "wifi" ? root.themeAccent : "transparent")
                border.width: 1
                clip: true
                
                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "transparent"
                    visible: root.appearanceMode === 2
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                        GradientStop { position: 0.7; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
                        GradientStop { position: 1.0; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
                    }
                    
                    border.color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
                    border.width: 1
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 11
                        color: "transparent"
                        border.color: root.glassBorderInner
                        border.width: 1
                    }
                }
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12
                    
                    Text {
                        text: root.networkIcon
                        color: root.themeAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: parent.width - 28
                        height: parent.height
                        clip: true

                        Text {
                            id: wifiText
                            text: root.wifiName
                            color: root.textColor
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                        }
                    }
                }

                MouseArea {
                    id: wifiMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.activeSubView = root.activeSubView === "wifi" ? "" : "wifi";
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 42
                radius: 12
                color: btMouseArea.containsMouse || root.activeSubView === "bt" ? root.btnHoverColor : root.btnColor
                border.color: root.appearanceMode === 2 ? "transparent" : (btMouseArea.containsMouse || root.activeSubView === "bt" ? root.themeAccent : "transparent")
                border.width: 1
                clip: true

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "transparent"
                    visible: root.appearanceMode === 2
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                        GradientStop { position: 0.7; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
                        GradientStop { position: 1.0; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
                    }
                    
                    border.color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
                    border.width: 1
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 11
                        color: "transparent"
                        border.color: root.glassBorderInner
                        border.width: 1
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12
                    
                    Text {
                        text: "󰂯"
                        color: root.themeAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: parent.width - 28
                        height: parent.height
                        clip: true

                        Text {
                            id: btText
                            text: root.btName
                            color: root.textColor
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                        }
                    }
                }

                MouseArea {
                    id: btMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.activeSubView = root.activeSubView === "bt" ? "" : "bt";
                    }
                }
            }
            
            Item {
                width: parent.width
                height: 32
                
                Row {
                    anchors.fill: parent
                    spacing: 12
                    
                    Text {
                        text: root.volLevel <= 0 ? "󰝟" : (root.volLevel < 30 ? "󰕿" : (root.volLevel < 70 ? "󰖀" : "󰕾"))
                        color: root.themeAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                    }
                    
                    Rectangle {
                        id: volTrack
                        width: parent.width - 28
                        height: 6
                        radius: 3
                        color: root.trackColor
                        border.color: root.appearanceMode === 2 ? root.glassBorderInner : "transparent"
                        border.width: root.appearanceMode === 2 ? 1 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: Math.max(0, Math.min(volTrack.width, volTrack.width * (root.volLevel / 100)))
                            height: parent.height
                            radius: 3
                            color: root.themeAccent
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            cursorShape: Qt.PointingHandCursor
                            onPressed: (mouse) => {
                                root.volDragging = true;
                                let p = Math.max(0, Math.min(100, Math.round((mouse.x / volTrack.width) * 100)));
                                root.volLevel = p;
                                setVolProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + p + "% && echo " + p + " > /tmp/island_vol"]
                                setVolProc.running = false; setVolProc.running = true;
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    let p = Math.max(0, Math.min(100, Math.round((mouse.x / volTrack.width) * 100)));
                                    if (p !== root.volLevel) {
                                        root.volLevel = p;
                                        setVolProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + p + "% && echo " + p + " > /tmp/island_vol"]
                                        setVolProc.running = false; setVolProc.running = true;
                                    }
                                }
                            }
                            onReleased: root.volDragging = false
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 32
                
                Row {
                    anchors.fill: parent
                    spacing: 12
                    
                    Text {
                        text: root.briLevel <= 0 ? "󰃛" : (root.briLevel < 50 ? "󰃞" : "󰃠")
                        color: root.themeAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                    }
                    
                    Rectangle {
                        id: briTrack
                        width: parent.width - 28
                        height: 6
                        radius: 3
                        color: root.trackColor
                        border.color: root.appearanceMode === 2 ? root.glassBorderInner : "transparent"
                        border.width: root.appearanceMode === 2 ? 1 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: Math.max(0, Math.min(briTrack.width, briTrack.width * (root.briLevel / 100)))
                            height: parent.height
                            radius: 3
                            color: root.themeAccent
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            cursorShape: Qt.PointingHandCursor

                            Timer {
                                id: ddcDebounce
                                interval: 120
                                onTriggered: {
                                    setDdcProc.command = ["bash", "-c", "ddcutil setvcp 10 " + root.briLevel + " --bus=4 --noverify >/dev/null 2>&1"]
                                    setDdcProc.running = false
                                    setDdcProc.running = true
                                }
                            }

                            onPressed: (mouse) => {
                                root.briDragging = true;
                                let p = Math.max(0, Math.min(100, Math.round((mouse.x / briTrack.width) * 100)));
                                root.briLevel = p;
                                setBriProc.command = ["bash", "-c", "brightnessctl set " + p + "% && echo " + p + " > /tmp/island_bri"]
                                setBriProc.running = false
                                setBriProc.running = true
                                ddcDebounce.restart();
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    let p = Math.max(0, Math.min(100, Math.round((mouse.x / briTrack.width) * 100)));
                                    if (p !== root.briLevel) {
                                        root.briLevel = p;
                                        setBriProc.command = ["bash", "-c", "brightnessctl set " + p + "% && echo " + p + " > /tmp/island_bri"]
                                        setBriProc.running = false
                                        setBriProc.running = true
                                        ddcDebounce.restart();
                                    }
                                }
                            }
                            onReleased: {
                                root.briDragging = false;
                                let p = root.briLevel;
                                setBriProc.command = ["bash", "-c", "brightnessctl set " + p + "% && echo " + p + " > /tmp/island_bri"]
                                setBriProc.running = false
                                setBriProc.running = true
                                setDdcProc.command = ["bash", "-c", "ddcutil setvcp 10 " + p + " --bus=4 --noverify >/dev/null 2>&1"]
                                setDdcProc.running = false
                                setDdcProc.running = true
                            }
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: 34
                spacing: 6
                
                Repeater {
                    model: [
                        { name: "Power", mode: "power-saver", icon: "󱈑" },
                        { name: "Regular", mode: "balanced", icon: "󰌨" },
                        { name: "Turbo", mode: "performance", icon: "󱐋" }
                    ]
                    
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: parent.height
                        radius: 9
                        color: root.powerProfile === modelData.mode ? root.themeAccent : root.btnColor
                        border.color: root.appearanceMode === 2 ? "transparent" : (root.powerProfile === modelData.mode ? root.themeAccent : root.trackColor)
                        border.width: 1
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: "transparent"
                            visible: root.appearanceMode === 2 && root.powerProfile !== modelData.mode
                            
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                                GradientStop { position: 0.7; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
                                GradientStop { position: 1.0; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
                            }
                            
                            border.color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
                            border.width: 1
                            
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: 8
                                color: "transparent"
                                border.color: root.glassBorderInner
                                border.width: 1
                            }
                        }
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 5
                            
                            Text {
                                text: modelData.icon
                                color: root.powerProfile === modelData.mode ? "#1a1b26" : root.textColor
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.name
                                color: root.powerProfile === modelData.mode ? "#1a1b26" : root.textColor
                                font.family: "Inter"
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.powerProfile = modelData.mode;
                                setProfileProc.command = ["bash", "-c", "powerprofilesctl set " + modelData.mode];
                                setProfileProc.running = false;
                                setProfileProc.running = true;
                            }
                        }
                    }
                }
            }
            
            Row {
                width: parent.width
                height: 32
                spacing: 8
                
                Repeater {
                    model: [
                        { name: "Dark", mode: 0 },
                        { name: "Light", mode: 1 },
                        { name: "Glass", mode: 2 }
                    ]
                    
                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: parent.height
                        radius: 9
                        color: root.appearanceMode === modelData.mode ? root.themeAccent : root.btnColor
                        border.color: root.appearanceMode === 2 ? "transparent" : (root.appearanceMode === modelData.mode ? root.themeAccent : root.trackColor)
                        border.width: 1
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: "transparent"
                            visible: root.appearanceMode === 2 && root.appearanceMode !== modelData.mode
                            
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                                GradientStop { position: 0.7; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
                                GradientStop { position: 1.0; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
                            }
                            
                            border.color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
                            border.width: 1
                            
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: 8
                                color: "transparent"
                                border.color: root.glassBorderInner
                                border.width: 1
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            color: root.appearanceMode === modelData.mode ? "#1a1b26" : root.textColor
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.appearanceMode = modelData.mode;
                                saveAppearanceProc.modeValue = modelData.mode.toString();
                                saveAppearanceProc.running = false;
                                saveAppearanceProc.running = true;
                            }
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: 32
                spacing: 8
                
                Repeater {
                    model: [
                        { name: "Island", layout: 0 },
                        { name: "Edge Connected", layout: 1 }
                    ]
                    
                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: parent.height
                        radius: 9
                        color: root.layoutStyle === modelData.layout ? root.themeAccent : root.btnColor
                        border.color: root.appearanceMode === 2 ? "transparent" : (root.layoutStyle === modelData.layout ? root.themeAccent : root.trackColor)
                        border.width: 1
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: "transparent"
                            visible: root.appearanceMode === 2 && root.layoutStyle !== modelData.layout
                            
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
                                GradientStop { position: 0.7; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.05) : Qt.rgba(0, 0, 0, 0.05) }
                                GradientStop { position: 1.0; color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.3) }
                            }
                            
                            border.color: root.isWallpaperLight ? Qt.rgba(255, 255, 255, 0.4) : Qt.rgba(0, 0, 0, 0.4)
                            border.width: 1
                            
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: 8
                                color: "transparent"
                                border.color: root.glassBorderInner
                                border.width: 1
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            color: root.layoutStyle === modelData.layout ? "#1a1b26" : root.textColor
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.layoutStyle = modelData.layout;
                                saveLayoutProc.layoutValue = modelData.layout.toString();
                                saveLayoutProc.running = false;
                                saveLayoutProc.running = true;
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: subIsland
        width: 400
        height: 600
        x: mainIsland.width + 16
        y: 0
        
        topLeftRadius: root.layoutStyle === 1 ? 0 : 18
        topRightRadius: root.layoutStyle === 1 ? 0 : 18
        bottomLeftRadius: 18
        bottomRightRadius: 18

        color: root.bgColor
        border.color: root.appearanceMode === 2 ? "transparent" : root.themeAccent
        border.width: 1
        clip: true

        opacity: root.activeSubView !== "" ? 1 : 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        GlassOverlay { targetNode: subIsland }

        Loader {
            id: subLoader
            anchors.fill: parent
            source: root.activeSubView === "wifi" ? "Views/WifiView.qml" : (root.activeSubView === "bt" ? "Views/BluetoothView.qml" : "")
            
            Binding { target: subLoader.item; property: "themeAccent"; value: root.themeAccent; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "appearanceMode"; value: root.appearanceMode; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "isWallpaperLight"; value: root.isWallpaperLight; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "glassBorderInner"; value: root.glassBorderInner; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "bgColor"; value: root.bgColor; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "btnColor"; value: root.btnColor; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "btnHoverColor"; value: root.btnHoverColor; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "textColor"; value: root.textColor; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "subTextColor"; value: root.subTextColor; when: subLoader.status === Loader.Ready }
            Binding { target: subLoader.item; property: "trackColor"; value: root.trackColor; when: subLoader.status === Loader.Ready }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -99
        onClicked: {
            root.expanded = false;
            root.activeSubView = "";
        }
    }

    Process {
        id: writeNet
        command: ["bash", "-c", "ETH=$(LC_ALL=C nmcli -t -f TYPE,NAME c s --active | awk -F: '/ethernet/ {print $2; exit}'); if [ -n \"$ETH\" ]; then echo \"eth|$ETH|0\" > /tmp/island_net; else WIFI=$(LC_ALL=C nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes'); if [ -n \"$WIFI\" ]; then W=$(echo \"$WIFI\" | cut -d: -f2); S=$(echo \"$WIFI\" | cut -d: -f3); echo \"wifi|$W|${S:-0}\" > /tmp/island_net; else echo 'none|Disconnected|0' > /tmp/island_net; fi; fi"]
    }

    Process {
        id: fetchBtName
        command: ["bash", "-c", "if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then DEV=$(bluetoothctl devices Connected 2>/dev/null | head -n1); if [ -n \"$DEV\" ]; then parts=($DEV); echo \"${parts[*]:2}\"; else echo 'Enabled'; fi; else echo 'Disconnected'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = text ? text.trim() : "";
                root.btName = out !== "" ? out : "Disconnected";
            }
        }
    }

    Process {
        id: fetchProfile
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = text ? text.trim() : "";
                if (out !== "") root.powerProfile = out;
            }
        }
    }

    Process {
        id: fetchVol
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        onExited: {
            var out = stdout ? (typeof stdout === "string" ? stdout : stdout.join(" ")).trim() : "";
            if (!root.volDragging && out !== "") {
                var match = out.match(/([0-9]+)%/);
                if (match) {
                    root.volLevel = parseInt(match[1]) || 0;
                } else {
                    var parts = out.split(" ");
                    if (parts.length >= 2) {
                        root.volLevel = Math.round(parseFloat(parts[1]) * 100);
                    }
                }
            }
        }
    }

    Process {
        id: fetchBri
        command: ["brightnessctl", "-m"]
        onExited: {
            var out = stdout ? (typeof stdout === "string" ? stdout : stdout.join("")).trim() : "";
            if (!root.briDragging && out !== "") {
                var parts = out.split(",");
                if (parts.length >= 4) {
                    root.briLevel = parseInt(parts[3].replace("%", "")) || 0;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            writeNet.running = false; writeNet.running = true;
            fetchVol.running = false; fetchVol.running = true;
            fetchBri.running = false; fetchBri.running = true;
            fetchProfile.running = false; fetchProfile.running = true;
            
            if (root.expanded) {
                fetchBtName.running = false; fetchBtName.running = true;
            }
            
            var netXhr = new XMLHttpRequest();
            netXhr.open("GET", "file:///tmp/island_net?t=" + new Date().getTime());
            netXhr.setRequestHeader("Cache-Control", "no-cache");
            netXhr.onreadystatechange = function() {
                if (netXhr.readyState === XMLHttpRequest.DONE && netXhr.responseText) {
                    var data = netXhr.responseText.trim().split("|");
                    if (data.length >= 3) {
                        root.connectionType = data[0];
                        root.wifiName = data[1];
                        root.wifiSignal = parseInt(data[2]) || 0;
                    }
                }
            }
            netXhr.send();
        }
    }

    Process { id: setVolProc }
    Process { id: setBriProc }
    Process { id: setDdcProc }
    Process { id: setProfileProc }
    
    Process {
        id: saveAppearanceProc
        property string modeValue: "0"
        command: ["bash", "-c", "mkdir -p ~/.config/quickshell && echo '" + modeValue + "' > ~/.config/quickshell/island_appearance"]
    }

    Process {
        id: saveLayoutProc
        property string layoutValue: "0"
        command: ["bash", "-c", "mkdir -p ~/.config/quickshell && echo '" + layoutValue + "' > ~/.config/quickshell/island_layout"]
    }
}