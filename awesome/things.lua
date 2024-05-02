-- black           = '#1e2127'
-- light-black     = '#5c6370'
-- red             = '#e06c75'
-- green           = '#98c379'
-- yellow          = '#d19a66'
-- blue            = '#61afef'
-- magenta         = '#c678dd'
-- cyan            = '#56b6c2'
-- white           = '#abb2bf'
-- light-white     = '#ffffff'
-- text            = '#abb2bf'
-- selection       = '#3a3f4b'
-- cursor          = '#5c6370'
-- background      = '#1e2127'


local awesome = awesome
local mouse = mouse
local capi = { keygrabber = keygrabber }
local theme_assets = require("beautiful.theme_assets")
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi


local theme = {}
theme.font          = "sans 8"
theme.icon_font     = "FiraMono Nerd Font"
theme.icon_theme    = "Papirus-Dark"
theme.bg_dark       = "#111111"
theme.bg_normal     = "#1e2127"
theme.bg_focus      = "#2a2f3b"
theme.bg_urgent     = "#e06c75"
theme.bg_minimize   = "#1e2127"
theme.bg_systray    = "#1e2127"
theme.bg_accent     = "#111111"
theme.fg_normal     = "#abb2bf"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#3a3f4b"
theme.fg_minimize   = "#3a3f4b"
theme.border_normal = "#1e2127"
theme.border_focus  = "#5c6370"
theme.border_marked = "#e06c75"
theme.accent        = '#56b6c2'
theme.useless_gap   = dpi(1)
theme.border_width  = dpi(1)
theme.icon_margin   = 16
theme.icon_size     = 32
theme.useless_gap   = 2.5
theme.wallpaper     = os.getenv("HOME").."/.config/awesome/nord-dark.png"
theme.icon_folder   = os.getenv("HOME")..'/.config/awesome/icons/'
theme.gap_single_client     = true
theme.menubar_border_color  = "#1e2127"
theme.menubar_border_width  = dpi(5)
theme.taglist_squares_sel   = theme_assets.taglist_squares_sel(dpi(4), theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(dpi(4), theme.fg_normal)


local helpers = {}
helpers.widget_parent = nil
helpers.action_widget = nil
helpers.set_shape = function(c, w, h) gears.shape.rounded_rect(c, w, h, 10) end
helpers.update_slider = function(component, command)
    awful.spawn.easy_async_with_shell(command, function(stdout)
        local value = string.gsub(stdout, "^%s*(.-)%s*$", "%1")
        if tonumber(value) ~= nil then component:set_value(tonumber(value)) end
    end)
end
helpers.key_command = function(num, component, command)
    return function ()
        local bright_value = tonumber(component:get_value())
        awful.spawn(command(bright_value + num))
        component:set_value(bright_value + num)
    end
end


--- @param icon string
--- @param desc string
--- @param id? string
local function constructor(icon, desc, id)
    return {icon = icon, desc = desc, id = id}
end

---@param self {icon: string}
---@return table
local function create_icon(self)
    if self.icon:sub(1, 1) ~= "/" then
        self.icon = theme.icon_folder .. self.icon .. ".svg"
    end

    return {
        id = "icon",
        image = self.icon,
        resize = true,
        opacity = 0.6,
        forced_height = theme.icon_size,
        forced_width = theme.icon_size,
        widget = wibox.widget.imagebox
    }
end

---@param self {icon: string, desc: string, command: function, state?: boolean}
---@return table
local function create_button(self)
    if self.state == nil then self.state = false end

    local icon_widget_with_margin = {
        create_icon(self),
        margins = theme.icon_margin,
        widget = wibox.container.margin
    }

    local result = wibox.widget({
        icon_widget_with_margin,
        bg = theme.bg_normal,
        widget = wibox.container.background
    })

    result:set_shape(helpers.set_shape)

    local old_cursor, old_wibox

    result:connect_signal("mouse::enter", function(c)
        c:set_bg(theme.bg_accent)
        pcall(function()
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand1"

            helpers.action_widget:set_markup(
                '<span color="' .. theme.fg_normal .. '">' .. self.desc .. '</span>')
        end)
    end)

    result:connect_signal("mouse::leave", function(c)
        c:set_bg(self.state and theme.bg_focus or theme.bg_normal)
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end

        helpers.action_widget:set_markup('<span> </span>')
    end)

    result:connect_signal("button::press", function()
        self:command()
        helpers.wibox_parent.visible = false
        capi.keygrabber.stop()
    end)

    return result
end

---@param self {id: string, command: function, icon: string, desc: string}
---@return table, table
local function create_slider(self)
    local icon_with_margin_widget = {
        create_icon(self),
        top = dpi(16),
        bottom = dpi(16),
        right = dpi(16),
        widget = wibox.container.margin
    }

    local slider_widget = {
        id = self.id,
        shape = helpers.set_shape,
        bar_shape = helpers.set_shape,
        bar_color = theme.fg_normal,
        bar_margins = { bottom = dpi(30), top = dpi(30) },
        bar_height = dpi(4),
        bar_width = dpi(10),
        bar_active_color = theme.fg_normal,
        handle_color = theme.fg_normal,
        handle_shape = helpers.set_shape,
        handle_width = dpi(16),
        handle_margins = { bottom = dpi(24), top = dpi(24) },
        handle_border_width = dpi(4),
        handle_border_color = theme.bg_normal,
        widget = wibox.widget.slider,
        maximum = 100,
    }

    local icon_with_margin_and_layout_widget = {
        id = "layout_widget",
        icon_with_margin_widget,
        slider_widget,
        layout = wibox.layout.fixed.horizontal
    }

    local icon_with_margin_and_layout_and_slider_and_margin_widget = {
        id = "margin_widget",
        icon_with_margin_and_layout_widget,
        forced_width = dpi(200),
        forced_height = dpi(64),
        left = dpi(16),
        right = dpi(16),
        widget = wibox.container.margin,
    }

    local result = wibox.widget({
        icon_with_margin_and_layout_and_slider_and_margin_widget,
        shape = helpers.set_shape,
        widget = wibox.container.background,
    })

    local exec_command = function() awful.spawn(
        self.command(result.margin_widget.layout_widget[self.id]:get_value()),
        false
    ) end

    result.margin_widget.layout_widget[self.id]:connect_signal(
        "property::value", exec_command)

    local old_cursor, old_wibox

    result:connect_signal("mouse::enter", function(c)
        c:set_bg(theme.bg_dark)
        c.margin_widget.layout_widget[self.id]:set_handle_border_color(theme.bg_dark)
        c:set_opacity(1)
        pcall(function()
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand1"

            helpers.action_widget:set_markup(
                '<span color="' .. theme.fg_normal .. '">' .. self.desc .. '</span>')
        end)
    end)

    result:connect_signal("mouse::leave", function(c)
        c:set_bg(theme.bg_normal)
        c.margin_widget.layout_widget[self.id]:set_handle_border_color(theme.bg_normal)
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end

        helpers.action_widget:set_markup('<span> </span>')
    end)

    return result, result.margin_widget.layout_widget[self.id]
end


local bright = constructor('sun', 'change bright (b,g)', "bright_widget")
bright.command = function(cmd) return "brightnessctl set " .. cmd .. "%" end
bright.component, bright.slider = create_slider(bright)
helpers.update_slider(bright.slider,
    "brightnessctl | grep -i  'current' | awk '{ print $4}' | tr -d \"(%)\"")

local volume = constructor('volume', 'change volume (v,o)', 'volume_widget')
volume.command = function(cmd) return "amixer set Master " .. cmd .. "%" end
volume.component, volume.slider = create_slider(volume)
helpers.update_slider(volume.slider,
    "amixer sget Master | \
    awk -F'[][]' '/Right:|Mono:/ && NF > 1 {sub(/%/, \"\"); printf \"%0.0f\", $2}'")

local mic = constructor('mic', 'change mic (m,i)', 'mic_widget')
mic.command = function(cmd) return "amixer set Capture " .. cmd .. "%" end
mic.component, mic.slider = create_slider(mic)
helpers.update_slider(mic.slider,
    "amixer sget Capture | \
    awk -F'[][]' '/Right:|Mono:/ && NF > 1 {sub(/%/, \"\"); printf \"%0.0f\", $2}'")


-- local blue = constructor('bluetooth', 'toggle bluetooth (t)')
-- blue.state = false
-- blue.on = "rfkill unblock bluetooth; sleep 1; bluetoothctl power on;"
-- blue.off = "bluetoothctl disconnect; bluetoothctl power off; rfkill block bluetooth;"
-- function blue:get_command() return self.state and self.off or self.on end
-- function blue:get_color() return self.state and theme.bg_normal or theme.bg_focus end
-- function blue:command() awful.spawn.easy_async_with_shell(self:get_command(), function()
--     self.component:set_bg(self:get_color())
--     self.state = not self.state
-- end) end
-- blue.component = create_button(blue)
-- awful.spawn.easy_async_with_shell("rfkill list bluetooth", function(out)
--     local statement = out:match("Soft blocked: yes") ~= "Soft blocked: yes"
--     blue.state = statement and false or true
--     blue.component:set_bg(statement and theme.bg_normal or theme.bg_focus)
-- end)

local shot = constructor('screenshot', 'print screen (p)')
function shot:command() awful.spawn.with_shell('gnome-screenshot') end
shot.component = create_button(shot)

-- local wifi = constructor('wifi', 'toggle wifi (w)')
-- wifi.state = false
-- wifi.on = "nmcli radio wifi on"
-- wifi.off = "nmcli radio wifi off"
-- function wifi:get_command() return self.state and self.off or self.on end
-- function wifi:get_color() return self.state and theme.bg_normal or theme.bg_focus end
-- function wifi:command() awful.spawn.easy_async_with_shell(self:get_command(), function()
--     self.component:set_bg(self:get_color())
--     self.state = not self.state
-- end) end
-- wifi.component = create_button(wifi)
-- awful.spawn.easy_async_with_shell("nmcli g | tail -n 1 | awk '{ print $1 }'", function(out)
--     local statement = string.gsub(out, "^%s*(.-)%s*$", "%1")
--     wifi.state = statement == "connected" and false or true
--     wifi.component:set_bg(statement == "connected" and theme.bg_normal or theme.bg_focus)
-- end)


local logout = constructor('log-out', 'log out (l)')
logout.command = awesome.quit
logout.component = create_button(logout)

local lock = constructor('lock', 'lock (k)')
lock.command = function() awful.spawn.with_shell("i3lock") end
lock.component = create_button(lock)

local reboot = constructor('refresh', 'reboot (r)')
reboot.command = function() awful.spawn.with_shell("reboot") end
reboot.component = create_button(reboot)

local suspend = constructor('moon', 'suspend (u)')
suspend.command = function() awful.spawn.with_shell("systemctl suspend") end
suspend.component = create_button(suspend)

local power = constructor('power', 'power off (s)')
power.command = function() awful.spawn.with_shell("shutdown now") end
power.component = create_button(power)


local keymap = {}
keymap["b"] = helpers.key_command(-5, bright.slider, bright.command)
keymap["g"] = helpers.key_command(5, bright.slider, bright.command)
keymap["v"] = helpers.key_command(-5, volume.slider, volume.command)
keymap["o"] = helpers.key_command(5, volume.slider, volume.command)
keymap["m"] = helpers.key_command(-5, mic.slider, mic.command)
keymap["i"] = helpers.key_command(5, mic.slider, mic.command)
keymap["l"] = logout.command
keymap["s"] = power.command
keymap["r"] = reboot.command
keymap["u"] = suspend.command
keymap["k"] = lock.command
-- keymap["t"] = blue.command
keymap["p"] = shot.command
keymap["Escape"] = function() capi.keygrabber.stop(); helpers.wibox_parent.visible = false end


local control = {}
function control.launch()
    local clock_widget = wibox.widget{
        widget = wibox.widget.textclock,
        format = "%A, %d %B, %H:%M",
        font = theme.font .. "Medium 13",
    }

    local action_widget = wibox.widget({
        text = ' ',
        widget = wibox.widget.textbox
    })

    local w = wibox({
        bg = beautiful.fg_normal,
        max_widget_size = 500,
        ontop = true,
        height = 500,
        width = 450,
        shape = helpers.set_shape
    })

    helpers.wibox_parent = w
    helpers.action_widget = action_widget

    w:set_bg(beautiful.bg_normal)

    local sliders = {
        volume.component,
        mic.component,
        bright.component,
        spacing = 8,
        layout = wibox.layout.fixed.vertical
    }

    local log_buttons = {
        shot.component,
        power.component,
        logout.component,
        suspend.component,
        spacing = 8,
        layout = wibox.layout.fixed.horizontal
    }

    -- local setting_buttons = {
    --     blue.component,
    --     wifi.component,
    --     spacing = 8,
    --     layout = wibox.layout.fixed.horizontal
    -- }

    local header_widget = {
        {
            action_widget,
            clock_widget,
            layout = wibox.layout.fixed.vertical
        },
        left = 16,
        right = 16,
        widget = wibox.container.margin
    }

    local sliders_buttons_and_action_widget = {
        header_widget,
        -- setting_buttons,
        sliders,
        log_buttons,
        spacing = 32,
        layout = wibox.layout.fixed.vertical
    }

    w:setup({
        sliders_buttons_and_action_widget,
        shape_border_width = 1,
        valign = 'center',
        layout = wibox.container.place
    })

    w.screen = mouse.screen
    w.visible = true

    awful.placement.centered(w)
    capi.keygrabber.run(function(_, key, event)
        if event == "release" or key == nil then return end
        local key_function = keymap[key]
        if type(key_function) == "function" then key_function() end
    end)
end


return { theme = theme, helpers = helpers, control = control }
