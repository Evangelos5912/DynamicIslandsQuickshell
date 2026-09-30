pragma Singleton
import QtQuick
import Quickshell
import QtCore

QtObject {
    id: root
    
    property var recentIds: []

    property var _settings: Settings {
        category: "AppLauncher"
        property string recentIdsSerialized: "[]"
    }

    Component.onCompleted: {
        try {
            recentIds = JSON.parse(_settings.recentIdsSerialized);
        } catch (e) {
            recentIds = [];
        }
    }

    function recordLaunch(id) {
        var list = recentIds.slice();
        var idx = list.indexOf(id);

        if (idx !== -1) {
            list.splice(idx, 1);
        }
        
        list.unshift(id);

        if (list.length > 12) {
            list = list.slice(0, 12);
        }

        recentIds = list;
        _settings.recentIdsSerialized = JSON.stringify(list);
    }

    function clearRecents() {
        recentIds = [];
        _settings.recentIdsSerialized = "[]";
    }
}