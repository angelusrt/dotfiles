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

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local theme = {}

theme.font          = "sans 8"
theme.icon_font     = "FiraMono Nerd Font"
theme.icon_theme    = "Papirus-Dark"

theme.bg_dark       = "#111111"
theme.bg_normal     = "#1e2127"
theme.bg_focus      = "#3a3f4b"
theme.bg_urgent     = "#e06c75"
theme.bg_minimize   = "#1e2127"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#abb2bf"
theme.fg_focus      = "#fff"
theme.fg_urgent     = "#3a3f4b"
theme.fg_minimize   = "#3a3f4b"

theme.useless_gap   = dpi(1)
theme.border_width  = dpi(1)
theme.border_normal = "#1e2127"
theme.border_focus  = "#5c6370"
theme.border_marked = "#e06c75"
theme.accent        = '#56b6c2'

theme.menubar_border_width  = dpi(5)
theme.menubar_border_color = "#1e2127"

theme.wallpaper = os.getenv("HOME").."/.config/awesome/nord-dark.png"
theme.icon_folder = os.getenv("HOME")..'/.config/awesome/components/icons/'

theme.useless_gap = 2.5
theme.gap_single_client = true

theme.taglist_squares_sel = theme_assets.taglist_squares_sel(dpi(4), theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(dpi(4), theme.fg_normal)

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
