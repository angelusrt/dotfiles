pcall(require, "luarocks.loader")

local awesome = awesome
local client = client
local screen = screen
local root = root
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local things = require("things")
-- local logout_popup = require("components.logout-popup")
-- local control_popup = require("components.control-popup")

require("awful.autofocus")

-- "global" variables
local terminal = "x-terminal-emulator"
local modkey = "Mod4"

-- errors 
local function notify_errors(err)
    naughty.notify({ preset = naughty.config.presets.critical, timeout = 2, title = "Erros", text = tostring(err) })
end

do
    if awesome.startup_errors then notify_errors(awesome.startup_errors) end

    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        notify_errors(err)
        in_error = false
    end)
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
-- beautiful.init(string.format("%s/.config/awesome/theme.lua", os.getenv("HOME")))
beautiful.init(string.format("%s/.config/awesome/things.lua", os.getenv("HOME")))

awful.layout.layouts = { awful.layout.suit.max, awful.layout.suit.tile }
menubar.utils.terminal = terminal

-- wallpaper
local function set_wallpaper(s) if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
    gears.wallpaper.maximized(wallpaper, s, true)
end end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    set_wallpaper(s)
    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
end)


local globalkeys = gears.table.join(
    awful.key({ modkey }, "r", function() awful.spawn("rofi -show 'window'") end),
    awful.key({ modkey }, "o", function() things.control.launch() end),

    awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("amixer -q -D pulse sset Master 5%-", false) end),
    awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("amixer -q -D pulse sset Master 5%+", false) end),
   awful.key({}, "XF86AudioMute", function() awful.spawn("amixer -D pulse set Master 1+ toggle", false) end),
   awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause", false) end),
   awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next", false) end),
   awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous", false) end),
    awful.key({}, "XF86MonBrightnessDown", function() awful.spawn("brightnessctl s 5%-") end),
    awful.key({}, "XF86MonBrightnessUp", function() awful.spawn("brightnessctl s +5%") end),

    awful.key({}, "Caps_Lock", function () awful.spawn.with_line_callback( "bash -c 'sleep 0.2 && xset q'", {
        stdout = function (line) if line:match("Caps Lock") then
          local status = line:gsub(".*(Caps Lock:%s+)(%a+).*", "%2")
          naughty.notify({ urgency = "normal", title = "Capslock", text = tostring(status), timeout = 2 })
        end end
    }) end),

    awful.key({ modkey, }, "Escape", awful.tag.history.restore),
    awful.key({ modkey, }, "j", function() awful.client.focus.byidx(1) end),
    awful.key({ modkey, }, "k", function() awful.client.focus.byidx(-1) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end),

    awful.key({ modkey, }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        if c then c:emit_signal( "request::activate", "key.unminimize", { raise = true }) end
    end),

    -- Standard program
    awful.key({ modkey, }, "t", function() awful.spawn(terminal) end),
    awful.key({ modkey, }, "b", function() awful.spawn("qutebrowser") end),
    awful.key({ modkey, }, "g", function() awful.spawn("gnome-screenshot") end),

    awful.key({ modkey, "Shift" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),
    awful.key({ modkey }, "p", menubar.show))

local clientkeys = gears.table.join(
    awful.key({ modkey }, "q", function(c) c:kill() end),
    awful.key({ modkey, "shift" }, "t", function(c) c.ontop = not c.ontop end),
    awful.key({ modkey, }, "m", function(c) c.maximized = not c.maximized; c:raise() end))

for i = 1, 9 do globalkeys = gears.table.join(globalkeys, awful.key({ modkey }, "#".. i + 9, function()
    local tag = awful.screen.focused().tags[i]; if tag then tag:view_only() end
end)) end

local clientbuttons = awful.util.table.join(
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end)

root.keys(globalkeys)

local rules = {{}, {}}
rules[1].rule = {}
rules[1].properties = {
    border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    raise = true,
    keys = clientkeys,
    buttons = clientbuttons,
    screen = awful.screen.preferred,
    placement = awful.placement.no_overlap + awful.placement.no_offscreen }
rules[2].rule_any = {
    instance = { "DTA", "copyq", "pinentry" },
    class = { "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin", "Sxiv", "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer" },
    name = { "Event Tester", },
    role = { "AlarmWindow", "ConfigManager", "pop-up", } }
rules[2].properties = { floating = true }
awful.rules.rules = rules

client.connect_signal("mouse::enter", function(c) c:emit_signal("request::activate", "mouse_enter", { raise = false }) end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("manage", function(c) c.shape = things.helpers.set_shape end)
client.connect_signal("manage", function(c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

menubar.left_label = ""
menubar.right_label = ""
menubar.show_categories = false
menubar.utils.lookup_icon = function () end
naughty.config.defaults.border_width = 0
naughty.config.defaults.margin = 10
naughty.config.defaults.width = 150
naughty.config.defaults.shape = things.helpers.set_shape

collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gears.timer({ timeout = 5, autostart = true, call_now = true, callback = function() collectgarbage("collect") end })

