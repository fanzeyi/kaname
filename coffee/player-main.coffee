
define ['jquery', 'underscore',
        '/coffee-dist/player-player.js',
        '/coffee-dist/player-setting.min.js',
        '/coffee-dist/player-keybinding.min.js'], ($, _, Player, Setting, KeyBinding) ->

    setting = new Setting()
    setting.loadConfig ->
        player = new Player(setting)
        player.startPlay()
    
        key_binding = new KeyBinding(player)
        key_binding.bindAll()
    
    chrome.notifications.onClicked.addListener ->
        chrome.app.window.current().show()
