-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

terminal = "kitty"
ide = "code"
browser = "firefox"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
shift = "Shift"

function print_debug (text_to_print)
  naughty.notify({ preset = naughty.config.presets.normal,
                     title = "Title",
                     text = text_to_print })
end

-- git test
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- beautiful.useless_gap = 5
-- beautiful.gap_single_client = true
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

beautiful.menu_height = 20
beautiful.menu_width = 100
beautiful.menu_bg_normal = "#374247"
beautiful.menu_bg_focus = "#F7F4E0"
--beautiful.menu_fg_normal = "#374247"
beautiful.menu_fg_focus = "#374247"

mymainmenu = awful.menu({ items = { { "Awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Open terminal", terminal },
                                    { "Files", "pcmanfm" },
                                    { " Browser", "firefox" }
                                  }
                        })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     --awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))


local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
-- screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
  function(s)
    print_debug("hello world")
    -- Wallpaper
    -- set_wallpaper(s)

    -- Each screen has its own tag table.
    --awful.tag({ "1", "2", "", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[2])
    awful.tag.add("", {
      icon = "/usr/share/icons/Adwaita/48x48/actions/folder-new-symbolic.symbolic.png",
      layout = awful.layout.suit.tile,
      screen = s,
      selected = true,
    })

    awful.tag.add("", {
      icon = "/usr/share/icons/Adwaita/48x48/actions/go-home-symbolic.symbolic.png",
      layout = awful.layout.suit.tile,
      screen = s,
    })

        -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
  end
)

--awful.tag.add("test", {
--  screen = 0,
--  layout = awful.layout.suit.tile,
--})

-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

--------- KEY BINDINGS ----------------------------------------------------
globalkeys = gears.table.join(

  awful.key({modkey}, "s", hotkeys_popup.show_help, 
    {description="show help", group="awesome"}),

  awful.key({modkey}, "Left", awful.tag.viewprev,
    {description = "view previous", group = "tag"}),
    
  awful.key({modkey}, "Right",  awful.tag.viewnext,
    {description = "view next", group = "tag"}),
    
  awful.key({modkey}, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),

  awful.key({modkey}, "j", function() awful.client.focus.byidx(1) end,
    {description = "focus next by index", group = "client"}),

  awful.key({modkey}, "k", function() awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),
    
  -- CUSTOM
  awful.key({modkey}, "o", function() awful.client.movetoscreen() end,
    {description = "move to next screen", group = "client"}),

  awful.key({modkey}, "Up", function() awful.client.focus.byidx(1) end,
    {description = "focus next by index", group = "client"}),

  awful.key({modkey}, "Down", function () awful.client.focus.byidx(-1) end,
    {description = "focus previous by index", group = "client"}),
  
  -- MUSTOC
  awful.key({modkey}, "w", function () mymainmenu:show() end,
    {description = "show main menu", group = "awesome"}),

  -- Layout manipulation
  awful.key({modkey, "Shift"}, "j", function () awful.client.swap.byidx(1) end,
    {description = "swap with next client by index", group = "client"}),

  awful.key({modkey, "Shift"}, "k", function () awful.client.swap.byidx(-1) end,
    {description = "swap with previous client by index", group = "client"}),

  awful.key({modkey, "Control"}, "j", function () awful.screen.focus_relative(1) end,
    {description = "focus the next screen", group = "screen"}),
 
  awful.key({modkey, "Control"}, "k", function () awful.screen.focus_relative(-1) end,
    {description = "focus the previous screen", group = "screen"}),
    
  awful.key({modkey}, "u", awful.client.urgent.jumpto,
    {description = "jump to urgent client", group = "client"}),
    
  -- awful.key({ modkey,           }, "Tab",
  --     function ()
  --         awful.client.focus.history.previous()
  --         if client.focus then
  --             client.focus:raise()
  --         end
  --     end,
  --     {description = "go back", group = "client"}),

  awful.key({modkey}, "Tab", function ()
    for c in awful.client.iterate(function (x) return true end) do
      client.focus = c
      client.focus:raise()
    end
  end),

  -- STANDARD PROGRAMS ----------------------------------------------
  awful.key({modkey}, "t", function ()
    awful.spawn(terminal) 
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Title",
                     text = "Start the Terminal dammit" })

  end,
  {description = "open a terminal", group = "launcher"}),
    
  awful.key({modkey}, "c", function () awful.spawn(ide) end,
    {description = "open ide", group = "launcher"}),
    
  awful.key({modkey}, "f", function () 
    awful.spawn("pcmanfm")
    print_debug("HELLO WORLD")
  end,
    {description = "open filemanager", group = "launcher"}),
    
  awful.key({modkey}, "i", function () awful.spawn(browser) end,
    {description = "open browser", group = "launcher"}),
    
  awful.key({modkey, shift}, "i", function () awful.spawn("google-chrome-stable") end,
    {description = "open chrome", group = "launcher"}),

  awful.key({modkey}, "l", function () awful.spawn("slock") end,
    {description = "lock the screen", group = "launcher"}),

  awful.key({ modkey, "Control" }, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
    
  awful.key({modkey, "Shift"}, "q", awesome.quit,
    {description = "quit awesome", group = "awesome"}),

  awful.key({modkey}, "l", function () awful.tag.incmwfact( 0.05) end,
    {description = "increase master width factor", group = "layout"}),
    
  awful.key({ modkey}, "h", function () awful.tag.incmwfact(-0.05) end,
    {description = "decrease master width factor", group = "layout"}),
    
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}),
    
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}),
    
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    {description = "increase the number of columns", group = "layout"}),
    
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    {description = "decrease the number of columns", group = "layout"}),
    
  awful.key({ modkey, "Shift"}, "space", function () awful.layout.inc(1) end,
    {description = "select next", group = "layout"}),
    
    --awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --         {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey }, "space", function () awful.util.spawn("rofi -show drun -show-icons") end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "d", function () awful.spawn.with_shell("~/scripts/reboot.sh") end,
              {description = "Reboot", group = "launcher"}),
    
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    
    awful.key({modkey}, "Return",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise() 
        end,
        {description = "toggle fullscreen", group = "client"}
    ),

    awful.key({ modkey,           }, "x",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "<",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    -- awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
    --           {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        --awful.key({ modkey }, "#" .. i + 9,
        --          function ()
        --                local screen = awful.screen.focused()
        --                local tag = screen.tags[i]
        --                if tag then
        --                   tag:view_only()
        --                end
        --          end,
        --          {description = "view tag #"..i, group = "tag"}),

        awful.key({modkey}, "#" .. i + 9,
          function()
            local tag = root.tags[i]
            if tag then
                tag:view_only()
            end
          end,
          {description = "view tag #"..i, group = "tag"}),

        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--    c:emit_signal("request::activate", "mouse_enter", {raise = false})
--end)

--client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart Applications
awful.spawn.with_shell("xrandr --output DVI-D-0 --pos 0x0 --output VGA-0 --pos 1920x0 --output HDMI-0 --pos 3840x0")
--awful.spawn.with_shell("killall conky")
--awful.spawn.with_shell("conky -c /home/limo/.config/conky/overview")
awful.spawn.with_shell("picom")
--awful.spawn.with_shell("nitrogen --restore")
--awful.spawn.with_shell("/home/limo/.config/polybar/launch.sh")
awful.spawn.with_shell("feh --bg-scale --no-fehbg /usr/share/wallpapers/chaos_invoked.jpg /usr/share/wallpapers/chaos_invoked.jpg /usr/share/wallpapers/chaos_invoked.jpg")


