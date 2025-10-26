-- Если LuaRocks установлен, убедитесь, что пакеты установленные через него находятся
-- (например, lgi). Если LuaRocks не установлен, ничего не делайте.
pcall(require, "luarocks.loader")
-- Стандартная awesome библиотека
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Библиотека виджетов и layouts
local wibox = require("wibox")
-- Библиотека тем
local beautiful = require("beautiful")
-- Библиотека уведомлений
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
awful.screen.set_auto_dpi_enabled(true)
-- Включить виджет помощи по горячим клавишам для VIM и других приложений
require("awful.hotkeys_popup.keys")
-- {{{ Обработка ошибок
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Ой, были ошибки во время запуска!",
        text = awesome.startup_errors
    })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Ой, произошла ошибка!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}
-- {{{ Определение переменных
-- Цветовая схема Solarized Light Yellow
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
-- Настройка цветов
beautiful.bg_normal     = "#fdf6e3"  -- base3
beautiful.bg_focus      = "#fdf6e3"  -- base3
beautiful.bg_urgent     = "#fdf6e3"  -- base3
beautiful.bg_minimize   = "#fdf6e3"  -- base3
beautiful.bg_systray    = "#fdf6e3"  -- base3
beautiful.fg_normal     = "#657b83"  -- base00
beautiful.fg_focus      = "#b58900"  -- base01/yellow
beautiful.fg_urgent     = "#dc322f"  -- red
beautiful.fg_minimize   = "#657b83"  -- base00
beautiful.border_normal = "#93a1a1"  -- base1
beautiful.border_focus  = "#b58900"  -- base01/yellow
beautiful.border_marked = "#dc322f"  -- red
-- Панель (wibar)
beautiful.wibar_bg      = "#fdf6e3"  -- base3
beautiful.wibar_fg      = "#657b83"  -- base00
-- Увеличенные шрифты
beautiful.font          = "Ubuntu 16"
beautiful.taglist_font  = "Ubuntu Bold 16"
-- Иконки (Nerd Fonts)
local icon_font = "Ubuntu Nerd Font 14"
-- Приложения по умолчанию
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
-- Клавиша-модификатор по умолчанию
modkey = "Mod4"
-- Layouts
awful.layout.layouts = {
    awful.layout.suit.tile.left,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}
-- Функция для установки обоев
local function set_wallpaper(s)
    gears.wallpaper.maximized("/home/redbird/Downloads/robot.jpg", s, true)
end
-- Обновление обоев при изменении геометрии экрана
screen.connect_signal("property::geometry", set_wallpaper)
-- }}}
-- {{{ Меню
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}
mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})
menubar.utils.terminal = terminal
-- }}}
-- {{{ Wibar
-- Индикатор и переключатель раскладки клавиатуры
mykeyboardlayout = awful.widget.keyboardlayout()
-- Виджет часов
mytextclock = wibox.widget.textclock("%a %d %b %H:%M", 10)

-- Лоток с ярлыками приложений
local app_launcher = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = 12,
}

-- Функция для создания кнопок приложений
local function create_app_button(icon, command, description)
    local button = wibox.widget {
        widget = wibox.widget.textbox,
        font = icon_font,
        text = icon,
        fg = "#b58900",  -- Жёлтый цвет
    }
    
    button:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn(command)
        end)
    ))
    
    -- Всплывающая подсказка
    awful.tooltip {
        objects = { button },
        text = description,
        mode = "outside",
        align = "right",
        margin_leftright = 8,
        margin_topbottom = 8,
    }
    
    return button
end

-- Функция для создания кнопки Onboard с особыми правилами
local function create_onboard_button()
    local button = wibox.widget {
        widget = wibox.widget.textbox,
        font = icon_font,
        text = "󰓎",  -- Иконка клавиатуры
        fg = "#b58900",  -- Жёлтый цвет
    }
    
    button:buttons(gears.table.join(
        awful.button({}, 1, function()
            -- Запускаем Onboard
            awful.spawn("onboard")
        end)
    ))
    
    -- Всплывающая подсказка
    awful.tooltip {
        objects = { button },
        text = "Onboard - Экранная клавиатура",
        mode = "outside",
        align = "right",
        margin_leftright = 8,
        margin_topbottom = 8,
    }
    
    return button
end

-- Создание кнопок для приложений
local firefox_button = create_app_button("", "firefox", "Firefox Browser")
local lutris_button = create_app_button("󰺵", "lutris", "Lutris Game Launcher")
local antimicrox_button = create_app_button("", "antimicrox", "AntiMicroX - Gamepad Mapping")
local corectrl_button = create_app_button("", "corectrl", "CoreCtrl - GPU Control")
local steam_button = create_app_button("", "steam", "Steam")
local onboard_button = create_onboard_button()

-- Добавление кнопок в лоток
app_launcher:add(firefox_button)
app_launcher:add(lutris_button)
app_launcher:add(antimicrox_button)
app_launcher:add(corectrl_button)
app_launcher:add(steam_button)
app_launcher:add(onboard_button)

-- WiFi widget
local wifi_icon = wibox.widget {
    widget = wibox.widget.textbox,
    font = icon_font,
    text = " ",  -- Иконка WiFi
    fg = "#b58900",  -- Жёлтый цвет
}
-- Клик по виджету WiFi
wifi_icon:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn("nm-connection-editor")
    end),
    awful.button({}, 3, function()
        awful.spawn("network-manager-applet")
    end)
))

-- Bluetooth widget
local bluetooth_icon = wibox.widget {
    widget = wibox.widget.textbox,
    font = icon_font,
    text = " ",
    fg = "#b58900",  -- Жёлтый цвет
}
-- Клик по виджету Bluetooth
bluetooth_icon:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn("blueman-manager")
    end)
))

-- Volume widget
local volume_icon = wibox.widget {
    widget = wibox.widget.textbox,
    font = icon_font,
    text = " ",
    fg = "#b58900",  -- Жёлтый цвет
}
local volume_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.font,
    text = "50%",
    fg = "#b58900",  -- Жёлтый цвет
}
local function update_volume()
    awful.spawn.easy_async("pamixer --get-volume", function(stdout)
        volume_widget:set_text(stdout:gsub("\n", "") .. "%")
    end)
end
local function volume_up()
    awful.spawn("pamixer --increase 4")
    update_volume()
end
local function volume_down()
    awful.spawn("pamixer --decrease 4")
    update_volume()
end
local function volume_toggle()
    awful.spawn("pamixer --toggle-mute")
    update_volume()
end
-- Клик по виджету громкости
volume_icon:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn("pavucontrol")
    end),
    awful.button({}, 4, volume_up),
    awful.button({}, 5, volume_down)
))
volume_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn("pavucontrol")
    end),
    awful.button({}, 3, volume_toggle),
    awful.button({}, 4, volume_up),
    awful.button({}, 5, volume_down)
))
-- Автообновление громкости
local volume_timer = gears.timer({ timeout = 5 })
volume_timer:connect_signal("timeout", update_volume)
volume_timer:start()
update_volume()

-- Разделитель
local separator = wibox.widget {
    widget = wibox.widget.textbox,
    text = " | ",
    fg = beautiful.fg_normal,
}

-- Taglist buttons
local taglist_buttons = gears.table.join(
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

-- Tasklist buttons
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end),
    awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

-- Create a wibox for each screen
awful.screen.connect_for_each_screen(function(s)
    -- Установка обоев
    set_wallpaper(s)
    -- Tags
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
    -- Create a promptbox
    s.mypromptbox = awful.widget.prompt()
    -- Create the wibar
    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        height = 32,  -- Увеличена высота
        bg = beautiful.wibar_bg or "#fdf6e3",
        fg = beautiful.wibar_fg or "#657b83",
        border_width = 0,
    })
    -- Setup wibar
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 8,
            awful.widget.taglist {
                screen = s,
                filter = awful.widget.taglist.filter.all,
                buttons = taglist_buttons,
                widget_template = {
                    {
                        {
                            id = 'text_role',
                            widget = wibox.widget.textbox,
                            font = beautiful.taglist_font,
                        },
                        left = 12,
                        right = 12,
                        top = 6,
                        bottom = 6,
                        widget = wibox.container.margin,
                    },
                    id = 'background_role',
                    widget = wibox.container.background,
                },
            },
            s.mypromptbox,
        },
        { -- Middle widget - часы по центру
            mytextclock,
            halign = "center",
            valign = "center",
            layout = wibox.container.place,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 12,
            -- Лоток с ярлыками приложений (перед раскладкой клавиатуры)
            app_launcher,
            separator,
            mykeyboardlayout,
            separator,
            wifi_icon,  -- Добавлен значок WiFi
            separator,
            bluetooth_icon,
            separator,
            {
                volume_icon,
                volume_widget,
                layout = wibox.layout.fixed.horizontal,
                spacing = 4,
            },
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Скриншоты
    awful.key({ }, "Print", function()
        awful.spawn("scrot -u -q 100 'screenshot_%Y-%m-%d-%H-%M-%S.png' -e 'mv $f ~/Pictures/'")
    end, {description = "Скриншот активного окна", group = "screenshot"}),

    awful.key({ modkey }, "Print", function()
        awful.spawn("scrot -s -q 100 'screenshot_%Y-%m-%d-%H-%M-%S.png' -e 'mv $f ~/Pictures/'")
    end, {description = "Скриншот области", group = "screenshot"}),

    awful.key({ "Shift" }, "Print", function()
        awful.spawn("scrot -q 100 'screenshot_%Y-%m-%d-%H-%M-%S.png' -e 'mv $f ~/Pictures/'")
    end, {description = "Скриншот всего экрана", group = "screenshot"}),

    awful.key({ modkey, "Shift" }, "Print", function()
        awful.spawn("scrot -q 100 -d 5 'screenshot_%Y-%m-%d-%H-%M-%S.png' -e 'mv $f ~/Pictures/'")
    end, {description = "Скриншот с задержкой 5 сек", group = "screenshot"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({}, "XF86AudioRaiseVolume", volume_up,
              {description = "volume up", group = "audio"}),
    awful.key({}, "XF86AudioLowerVolume", volume_down,
              {description = "volume down", group = "audio"}),
    awful.key({}, "XF86AudioMute", volume_toggle,
              {description = "volume mute", group = "audio"}),
    awful.key({ modkey }, "Up", volume_up,
              {description = "volume up", group = "audio"}),
    awful.key({ modkey }, "Down", volume_down,
              {description = "volume down", group = "audio"}),
    awful.key({ modkey, "Shift" }, "m", volume_toggle,
              {description = "volume mute", group = "audio"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  if c then
                    c:emit_signal("request::activate", "key.unminimize", {raise = true})
                  end
              end,
              {description = "restore minimized", group = "client"}),
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt = "Run Lua code: ",
                    textbox = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
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

-- Bind all key numbers to tags
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         tag:view_only()
                      end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #"..i, group = "tag"}),
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
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #"..i, group = "tag"})
    )
end

root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- Правило по умолчанию
    { rule = {},
      properties = {
         border_width = beautiful.border_width,
         border_color = beautiful.border_normal,
         focus = awful.client.focus.filter,
         raise = true,
         keys = clientkeys,
         buttons = clientbuttons,
         screen = awful.screen.preferred,
         placement = awful.placement.no_overlap + awful.placement.no_offscreen
      }
    },
    -- Правила для плавающих окон
    { rule_any = {
        instance = {
          "DTA", "copyq", "pinentry",
        },
        class = {
          "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin",
          "Sxiv", "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewup",
          "Onboard"  -- Добавляем Onboard в плавающие окна
        },
        name = { "Event Tester" },
        role = { "AlarmWindow", "ConfigManager", "pop-up" }
      },
      properties = { floating = true }
    },
    -- Специальное правило для Onboard
    {
        rule = { class = "Onboard" },
        properties = {
            floating = true,
            placement = awful.placement.center,  -- Размещаем по центру
            width = 800,  -- Ширина окна
            height = 300,  -- Высота окна
            skip_taskbar = true,  -- Не показывать в панели задач
            sticky = true,  -- Окно поверх всех
            ontop = true   -- Всегда поверх других окон
        }
    },
    -- Правила для corectrl и antimicrox
    {
        rule = { class = "corectrl" },
        properties = {
            tag = awful.screen.focused().tags[5],
            switchtotag = true,
        }
    },
    {
        rule = { class = "antimicrox" },
        properties = {
            tag = awful.screen.focused().tags[5],
            switchtotag = true,
        }
    }
}
-- }}}

-- {{{ Autostart
-- Автозапуск приложений при старте Awesome
awesome.connect_signal("startup", function()
    -- Запускаем приложения с задержкой для стабильности
    gears.timer.start_new(2, function()
        -- Запускаем CoreCtrl (только если не запущен)
        awful.spawn.with_shell("pgrep -x corectrl > /dev/null || corectrl")
        
        -- Запускаем AntiMicroX (только если не запущен)
        awful.spawn.with_shell("pgrep -x antimicrox > /dev/null || antimicrox --profile ~/desktop.gamecontroller.amgp")
        
        return false
    end)
end)

-- Перемещаем окна CoreCtrl и AntiMicroX на 5 тег при их появлении
client.connect_signal("manage", function(c)
    if c.class then
        local class_lower = c.class:lower()
        if class_lower:match("corectrl") or class_lower:match("antimicrox") then
            gears.timer.delayed_call(function()
                if c and c.valid then
                    local tag = awful.screen.focused().tags[5]
                    if tag then
                        c:move_to_tag(tag)
                        if not tag.selected then
                            tag:view_only()
                        end
                    end
                end
            end)
        end
    end
end)
-- }}}

-- {{{ Signals
client.connect_signal("manage", function (c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("request::titlebars", function(c)
    -- Пустое тело функции — заголовки не создаются
end)

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
