-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function () 
   	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("~/.config/quickshell/components/Scripts/launch.sh")
	hl.exec_cmd('gsettings set org.gnome.desktop.interface icon-theme "YAMIS"')
	hl.exec_cmd("bash ~/.config/quickshell/components/Scripts/media-bridge.sh &")
	hl.exec_cmd("wal -R")
	hl.exec_cmd("hyprlock")
	hl.exec_cmd("hypridle &")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)



