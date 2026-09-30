import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root
    anchors.fill: parent

    property string themeAccent: "#89b4fa"
    property bool isDraggingWindow: false

    property int appearanceMode: 0 
    property bool isWallpaperLight: false

    property color glassBgColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05)
    property color glassBorderColor: isWallpaperLight ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.15)
    property color glassInnerBg: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(0, 0, 0, 0.15)
    property color glassHoverColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.1)
    property color glassTextColor: isWallpaperLight ? "#1a1b26" : "#ffffff"
    property color glassSubTextColor: isWallpaperLight ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(1, 1, 1, 0.6)

    property color cardBgColor: appearanceMode === 0 ? "#181825" : (appearanceMode === 1 ? "#e8e8ed" : glassBgColor)
    property color cardBorderColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassBorderColor)
    property color innerBgColor: appearanceMode === 0 ? "#1a1b26" : (appearanceMode === 1 ? "#ffffff" : glassInnerBg)
    property color innerHoverColor: appearanceMode === 0 ? "#313244" : (appearanceMode === 1 ? "#d1d1d6" : glassHoverColor)
    property color textColor: appearanceMode === 0 ? "#cdd6f4" : (appearanceMode === 1 ? "#1d1d1f" : glassTextColor)
    property color subTextColor: appearanceMode === 0 ? "#6c7086" : (appearanceMode === 1 ? "#86868b" : glassSubTextColor)

    component DarkFrostOverlay: Rectangle {
        anchors.fill: parent
        radius: parent.radius
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
            radius: parent.radius - 1
            color: "transparent"
            border.color: root.isWallpaperLight ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
        }
    }

    property string searchQuery: ""
    property int selectedIndex: 0
    readonly property bool isSearching: searchQuery.trim() !== ""
    property var fileResults: []

    property var filteredApps: {
        var q = searchQuery.trim().toLowerCase();
        if (q === "") return [];
        
        var vals = DesktopEntries.applications.values;
        return vals.filter(function (e) {
            if (e.name.toLowerCase().indexOf(q) !== -1) return true;
            if (e.genericName && e.genericName.toLowerCase().indexOf(q) !== -1) return true;
            for (var i = 0; i < e.keywords.length; i++) {
                if (e.keywords[i].toLowerCase().indexOf(q) !== -1) return true;
            }
            return false;
        }).sort(function (a, b) {
            return a.name.localeCompare(b.name);
        }).slice(0, 5); 
    }

    function getIconForClass(className) {
        if (!className) return "";
        var c = className.toLowerCase();
        var vals = DesktopEntries.applications.values;
        for (var i = 0; i < vals.length; i++) {
            var app = vals[i];
            if (app.name.toLowerCase().indexOf(c) !== -1 || c.indexOf(app.name.toLowerCase()) !== -1) {
                return app.icon;
            }
        }
        return "";
    }

    onSearchQueryChanged: {
        selectedIndex = 0;
        if (searchQuery.trim().length > 2) {
            searchDebounce.restart();
        } else {
            searchDebounce.stop();
            fileResults = [];
        }
    }

    function launchEntry(entry) {
        AppLauncherState.recordLaunch(entry.id);
        entry.execute();
        closeLauncher();
    }

    function executeCustom(cmd) {
        actionProc.command = ["bash", "-c", cmd];
        actionProc.running = false;
        actionProc.running = true;
        closeLauncher();
    }

    function closeLauncher() {
        searchInput.text = "";
        root.searchQuery = "";
        shCompact.running = false;
        shCompact.running = true;
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            root.searchQuery = "";
            root.selectedIndex = 0;
            searchInput.forceActiveFocus();
        }
    }

    Item {
        id: searchHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        height: 56
        z: 100 

        Rectangle {
            anchors.fill: parent
            color: root.cardBgColor
            radius: 14
            border.color: root.appearanceMode === 2 ? "transparent" : (searchInput.activeFocus ? root.themeAccent : root.cardBorderColor)
            border.width: root.appearanceMode === 2 ? 0 : (searchInput.activeFocus ? 2 : 1)

            DarkFrostOverlay {}

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: root.themeAccent
                border.width: 1
                visible: root.appearanceMode === 2 && searchInput.activeFocus
            }

            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "🔍"
                    color: root.themeAccent
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchInput
                    width: parent.width - 40
                    height: parent.height
                    color: root.textColor
                    selectionColor: root.themeAccent
                    font.family: "Inter"
                    font.pixelSize: 18
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    clip: true

                    Text {
                        text: "Search apps, files, web, or calculate..."
                        color: root.subTextColor
                        font.family: "Inter"
                        font.pixelSize: 18
                        visible: !parent.text
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onTextChanged: root.searchQuery = text

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Escape) {
                            closeLauncher();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.filteredApps.length > 0) {
                                root.launchEntry(root.filteredApps[0]);
                            } else if (root.searchQuery.trim() !== "") {
                                executeCustom("xdg-open \"https://duckduckgo.com/?q=" + root.searchQuery.trim() + "\"");
                            }
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }

    property var liveWindows: []
    
    Item {
        anchors.top: searchHeader.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        z: 1 

        Flickable {
            id: wsView
            anchors.fill: parent
            visible: !root.isSearching
            contentWidth: wsRow.width
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                spacing: 12
                Text {
                    text: "WORKSPACES - Hold SUPER & Drag to Move Windows"
                    color: root.subTextColor
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                Row {
                    id: wsRow
                    spacing: 16

                    Repeater {
                        model: 9
                        Rectangle {
                            id: wsCard
                            property int wsId: index + 1
                            property bool isTarget: false
                            
                            width: 320 
                            height: 225 
                            color: root.cardBgColor
                            radius: 12
                            border.color: root.appearanceMode === 2 ? "transparent" : (isTarget || (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId) ? root.themeAccent : root.cardBorderColor)
                            border.width: root.appearanceMode === 2 ? 0 : (isTarget ? 3 : 2)
                            clip: false 

                            DarkFrostOverlay {}

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.color: root.themeAccent
                                border.width: wsCard.isTarget ? 3 : 2
                                visible: root.appearanceMode === 2 && (wsCard.isTarget || (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsCard.wsId))
                            }

                            DropArea {
                                anchors.fill: parent
                                keys: ["clientWindow"]
                                onEntered: wsCard.isTarget = true
                                onExited: wsCard.isTarget = false
                                onDropped: function(drop) {
                                    wsCard.isTarget = false;
                                    if (drop.source && drop.source.clientAddress) {
                                        executeCustom("hyprctl dispatch movetoworkspace " + wsCard.wsId + ",address:" + drop.source.clientAddress);
                                        clientsDumpProc.running = false;
                                        clientsDumpProc.running = true;
                                        drop.accept();
                                    }
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "Workspace " + wsCard.wsId
                                    color: (wsCard.isTarget || (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsCard.wsId)) ? root.themeAccent : root.textColor
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Rectangle {
                                    width: 300
                                    height: 168
                                    color: root.innerBgColor
                                    radius: 6
                                    border.color: root.appearanceMode === 2 ? "transparent" : root.cardBorderColor
                                    border.width: root.appearanceMode === 2 ? 0 : 1
                                    clip: false

                                    DarkFrostOverlay {}

                                    Repeater {
                                        model: root.liveWindows
                                        delegate: Rectangle {
                                            id: winRect
                                            property int clientWsId: modelData.workspace ? (modelData.workspace.id !== undefined ? modelData.workspace.id : modelData.workspace) : -1
                                            visible: clientWsId === wsCard.wsId && !modelData.hidden

                                            property string clientAddress: modelData.address
                                            property real cx: modelData.at !== undefined ? modelData.at[0] : (modelData.x || 0)
                                            property real cy: modelData.at !== undefined ? modelData.at[1] : (modelData.y || 0)
                                            property real cw: modelData.size !== undefined ? modelData.size[0] : (modelData.width || 0)
                                            property real ch: modelData.size !== undefined ? modelData.size[1] : (modelData.height || 0)

                                            property real mx: Math.floor(cx / 1920) * 1920
                                            property real my: Math.floor(cy / 1080) * 1080

                                            property real baseX: (cx - mx) * (300 / 1920)
                                            property real baseY: (cy - my) * (168 / 1080)

                                            x: dragArea.drag.active ? x : baseX
                                            y: dragArea.drag.active ? y : baseY
                                            width: Math.max(cw * (300 / 1920), 4)
                                            height: Math.max(ch * (168 / 1080), 4)

                                            color: Hyprland.focusedClient && Hyprland.focusedClient.address === clientAddress ? root.themeAccent : root.subTextColor
                                            radius: 4
                                            border.color: root.appearanceMode === 2 ? Qt.rgba(0,0,0,0.3) : root.innerBgColor
                                            border.width: 1
                                            opacity: dragArea.drag.active ? 0.95 : 0.85
                                            z: dragArea.drag.active ? 100 : 1

                                            Drag.active: dragArea.drag.active
                                            Drag.source: winRect
                                            Drag.keys: ["clientWindow"]
                                            Drag.hotSpot.x: width / 2
                                            Drag.hotSpot.y: height / 2

                                            MouseArea {
                                                id: dragArea
                                                anchors.fill: parent
                                                drag.target: winRect
                                                onPressed: function(mouse) {
                                                    if (mouse.modifiers & Qt.MetaModifier) {
                                                        root.isDraggingWindow = true;
                                                        var globalPos = mapToItem(wsView, 0, 0);
                                                        winRect.parent = wsView;
                                                        winRect.x = globalPos.x;
                                                        winRect.y = globalPos.y;
                                                        mouse.accepted = true;
                                                    } else { mouse.accepted = false; }
                                                }
                                                onReleased: { root.isDraggingWindow = false; if (drag.active) winRect.Drag.drop(); }
                                                onCanceled: root.isDraggingWindow = false;
                                            }

                                            property string winClass: modelData.initialClass || modelData.class || modelData.title || ""
                                            property string resolvedIcon: root.getIconForClass(winClass)

                                            Image {
                                                anchors.centerIn: parent
                                                width: Math.min(parent.width * 0.6, 24)
                                                height: Math.min(parent.height * 0.6, 24)
                                                source: parent.resolvedIcon !== "" ? "image://icon/" + parent.resolvedIcon : ""
                                                visible: parent.resolvedIcon !== ""
                                                smooth: true
                                                mipmap: true
                                                asynchronous: true
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: parent.resolvedIcon === ""
                                                text: parent.winClass.length > 0 ? parent.winClass.charAt(0).toUpperCase() : ""
                                                color: root.appearanceMode === 0 ? "#1a1b26" : "#ffffff"
                                                font.family: "Inter"
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                z: -1
                                onClicked: executeCustom("hyprctl dispatch workspace " + wsCard.wsId)
                            }
                        }
                    }
                }
            }
        }

        Flickable {
            anchors.fill: parent
            visible: root.isSearching
            contentWidth: width
            contentHeight: contentCol.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentCol
                width: parent.width
                spacing: 24

                Column {
                    width: parent.width
                    spacing: 8
                    visible: root.filteredApps.length > 0

                    Text { text: "APPS"; color: root.subTextColor; font.family: "Inter"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.2 }

                    Repeater {
                        model: root.filteredApps
                        Rectangle {
                            width: parent.width
                            height: 48
                            radius: 10
                            color: root.appearanceMode === 2 ? "transparent" : (appMouse.containsMouse ? root.innerHoverColor : root.cardBgColor)
                            border.color: root.appearanceMode === 2 ? "transparent" : root.cardBorderColor
                            border.width: root.appearanceMode === 2 ? 0 : 1
                            Behavior on color { ColorAnimation { duration: 100 } }

                            DarkFrostOverlay {}

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.color: root.themeAccent
                                border.width: 1
                                visible: root.appearanceMode === 2 && appMouse.containsMouse
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                spacing: 16
                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 28; height: 28
                                    source: modelData.icon !== "" ? "image://icon/" + modelData.icon : ""
                                    smooth: true; mipmap: true
                                    asynchronous: true
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    color: root.textColor
                                    font.family: "Inter"
                                    font.pixelSize: 15
                                    font.bold: true
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: modelData.genericName !== ""
                                    text: "— " + modelData.genericName
                                    color: root.subTextColor
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                }
                            }
                            MouseArea {
                                id: appMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.launchEntry(modelData)
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 8
                    visible: root.fileResults.length > 0

                    Text { text: "FILES & FOLDERS"; color: root.subTextColor; font.family: "Inter"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.2 }

                    Repeater {
                        model: root.fileResults
                        Rectangle {
                            width: parent.width
                            height: 40
                            radius: 8
                            color: root.appearanceMode === 2 ? "transparent" : (fileMouse.containsMouse ? root.innerHoverColor : root.cardBgColor)
                            border.color: root.appearanceMode === 2 ? "transparent" : root.cardBorderColor
                            border.width: root.appearanceMode === 2 ? 0 : 1
                            
                            property string itemType: modelData.split("|")[0]
                            property string itemPath: modelData.split("|").slice(1).join("|")

                            DarkFrostOverlay {}

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.color: root.themeAccent
                                border.width: 1
                                visible: root.appearanceMode === 2 && fileMouse.containsMouse
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                spacing: 12
                                Text { text: parent.parent.itemType === "d" ? "📁" : "📄"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: parent.parent.itemPath
                                    color: root.textColor
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    elide: Text.ElideLeft
                                    width: parent.width - 50
                                }
                            }
                            MouseArea {
                                id: fileMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (parent.itemType === "d") {
                                        executeCustom("dolphin \"" + parent.itemPath + "\"");
                                    } else {
                                        executeCustom("kitty -e nvim \"" + parent.itemPath + "\"");
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Text { text: "ACTIONS"; color: root.subTextColor; font.family: "Inter"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.2 }

                    Row {
                        spacing: 12
                        
                        Rectangle {
                            width: 180; height: 42; radius: 8
                            color: webMouse.containsMouse ? root.themeAccent : (root.appearanceMode === 2 ? "transparent" : root.cardBgColor)
                            border.color: root.appearanceMode === 2 && !webMouse.containsMouse ? "transparent" : root.themeAccent
                            border.width: 1

                            DarkFrostOverlay { visible: root.appearanceMode === 2 && !webMouse.containsMouse }

                            Row { 
                                anchors.centerIn: parent; spacing: 8
                                Text { text: "🌐"; font.pixelSize: 14 }
                                Text { 
                                    text: "Search Web"
                                    color: webMouse.containsMouse ? (root.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : root.themeAccent
                                    font.family: "Inter"; font.bold: true; font.pixelSize: 13 
                                }
                            }
                            MouseArea {
                                id: webMouse
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: executeCustom("xdg-open \"https://duckduckgo.com/?q=" + root.searchQuery.trim() + "\"")
                            }
                        }

                        Rectangle {
                            width: 180; height: 42; radius: 8
                            color: ytMouse.containsMouse ? "#f38ba8" : (root.appearanceMode === 2 ? "transparent" : root.cardBgColor)
                            border.color: root.appearanceMode === 2 && !ytMouse.containsMouse ? "transparent" : "#f38ba8"
                            border.width: 1

                            DarkFrostOverlay { visible: root.appearanceMode === 2 && !ytMouse.containsMouse }

                            Row { 
                                anchors.centerIn: parent; spacing: 8
                                Text { text: "▶"; color: ytMouse.containsMouse ? (root.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : "#f38ba8"; font.pixelSize: 12 }
                                Text { 
                                    text: "Search YouTube"
                                    color: ytMouse.containsMouse ? (root.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : "#f38ba8"
                                    font.family: "Inter"; font.bold: true; font.pixelSize: 13 
                                }
                            }
                            MouseArea {
                                id: ytMouse
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: executeCustom("xdg-open \"https://www.youtube.com/results?search_query=" + root.searchQuery.trim() + "\"")
                            }
                        }

                        Rectangle {
                            width: 180; height: 42; radius: 8
                            color: calcMouse.containsMouse ? "#a6e3a1" : (root.appearanceMode === 2 ? "transparent" : root.cardBgColor)
                            border.color: root.appearanceMode === 2 && !calcMouse.containsMouse ? "transparent" : "#a6e3a1"
                            border.width: 1
                            visible: root.searchQuery.match(/^[0-9\+\-\*\/\.\(\) ]+$/) !== null 

                            DarkFrostOverlay { visible: root.appearanceMode === 2 && !calcMouse.containsMouse }

                            Row { 
                                anchors.centerIn: parent; spacing: 8
                                Text { text: "🔢"; font.pixelSize: 14 }
                                Text { 
                                    text: "Calculate & Copy"
                                    color: calcMouse.containsMouse ? (root.appearanceMode === 0 ? "#1a1b26" : "#ffffff") : "#a6e3a1"
                                    font.family: "Inter"; font.bold: true; font.pixelSize: 13 
                                }
                            }
                            MouseArea {
                                id: calcMouse
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: executeCustom("echo $((" + root.searchQuery.trim() + ")) | wl-copy")
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: searchDebounce
        interval: 250
        repeat: false
        onTriggered: {
            var q = root.searchQuery.trim().replace(/'/g, "");
            var safeCmd = "if command -v fd >/dev/null 2>&1; then fd -i -a '" + q + "' ~ --max-results 4; else find ~ -maxdepth 4 -iname '*" + q + "*' 2>/dev/null | head -n 4; fi | while read p; do if [ -d \"$p\" ]; then echo \"d|$p\"; else echo \"f|$p\"; fi; done";
            
            fileSearchProc.command = ["bash", "-c", safeCmd];
            fileSearchProc.running = false;
            fileSearchProc.running = true;
        }
    }

    Process {
        id: fileSearchProc
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text ? this.text.trim() : "";
                if (output.length > 0) root.fileResults = output.split("\n");
                else root.fileResults = [];
            }
        }
    }

    Timer {
        id: initTimer
        interval: 350
        running: root.visible
        repeat: false
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
                    try { root.liveWindows = JSON.parse(xhr.responseText); } catch(e) { root.liveWindows = []; }
                }
            }
            xhr.send();
        }
    }

    Timer {
        interval: 1000
        running: root.visible && !root.isSearching && !root.isDraggingWindow 
        repeat: true
        onTriggered: { clientsDumpProc.running = false; clientsDumpProc.running = true; }
    }

    Process { id: shCompact; command: ["bash", "-c", "echo 'compact' > /tmp/island_mode"] }
    Process { id: actionProc }
}