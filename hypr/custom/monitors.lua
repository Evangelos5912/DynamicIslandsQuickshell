------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@144",
    position = "1920x0",
    scale = 1,
    reserved_area = { top = 15, bottom = 0, left = 0, right = 0 }
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@144",
    position = "0x0",
    scale = 1,
    reserved_area = { top = 15, bottom = 0, left = 0, right = 0 }
})

