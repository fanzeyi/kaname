define ['jquery', 
        '/coffee-dist/player-lastfm.js', 
        '/coffee-dist/utils.js'], ($, LastFM, openView) ->

    class Setting
    
        constructor: ->
            @logined_username = $("#js-logined-username")
            @kbps_setting = $("#js-setting-kbps")
    
            @main_panel = $("#js-setting-main")
            @login_panel = $("#js-setting-login-panel")
    
            @login_line = $("#js-setting-login-line")
            @panel_cancel = $(".js-setting-panel-cancel")
            @subsetting_panel = $(".js-subsetting-panel")
    
            @login_username = $("#js-setting-login-username")
            @login_like = $("#js-setting-login-like")
            @login_listened = $("#js-setting-login-listened")
            @login_banned = $("#js-setting-login-banned")
            @login_ispro = $("#js-setting-login-ispro")
            @login_prolength = $("#js-setting-login-prolength")
            @login_logout = $("#js-setting-login-logout")
    
            @notification_setting = $("#js-notification-setting")
    
            @lastfm = new LastFM '3a79de48b56292f6a6daa967cdec2ed2', '75428b69cec448a9cd4c9b504e719941'
    
            @lastfm_line = $("#js-setting-lastfm-line")
            @lastfm_panel = $("#js-setting-lastfm-panel")
            @lastfm_value = $("#js-setting-lastfm-value")
            @lastfm_revoke = $("#js-setting-lastfm-revoke")
    
            self = this
    
            chrome.storage.sync.get "token", (val) ->
                self.token = val.token
                self.logined_username.text val.token.douban_user_name
    
            @kbps_setting.bind "change", ->
                self.config.kbps = self.kbps_setting.val()
                self.saveConfig()
            
            @login_line.bind "click", ->
                self.main_panel.addClass "side-out"
                self.login_panel.addClass "side-in"
                
                $.ajax
                    url: "https://api.douban.com/v2/fm/user_info"
                    type: "GET"
                    headers:
                        Authorization: "Bearer " + self.token.access_token
                    dataType: "JSON"
                    success: (user) ->
                        self.login_username.text user.name
                        self.login_like.text user.liked_num + " 首"
                        self.login_listened.text user.played_num + " 首"
                        self.login_banned.text user.banned_num + " 首"
                        if user.pro_status is "S"
                            self.login_ispro.text "是"
                        else if user.pro_status is "E"
                            self.login_ispro.text "已过期"
                        else
                            self.login_ispro.text "否"
                        self.login_prolength.text user.pro_expire_date
    
            @lastfm_line.bind "click", ->
                if not self.config.lastfm
                    openView "lastfm", "lastfm.html", (win) ->
                        win.onClosed.addListener ->
                            chrome.storage.sync.get "lastfm", (lastfm) ->
                                console.log lastfm
                                if not lastfm?
                                    toast = new Toast "Last.fm 绑定失败"
                                    toast.show()
                                    return
    
                                self.config.lastfm = lastfm.lastfm
                                console.log self.config
    
                                self.saveConfig (config) ->
                                    console.log config
                                    console.log self.config
                                    self.renderConfig config
                                    self.main_panel.addClass "side-out"
                                    self.lastfm_panel.addClass "side-in"
                else
                    self.main_panel.addClass "side-out"
                    self.lastfm_panel.addClass "side-in"
    
            @lastfm_revoke.bind "click", ->
                self.config.lastfm = undefined
                self.saveConfig (config)->
                    self.renderConfig config
                    self.subsetting_panel.removeClass "side-in"
                    self.main_panel.removeClass "side-out"
    
            @login_logout.bind "click", ->
                chrome.storage.sync.remove "token", ()->
                    openView "login", "login.html", ->
                        chrome.app.window.current().close()
            
            @panel_cancel.bind "click", ->
                self.subsetting_panel.removeClass "side-in"
                self.main_panel.removeClass "side-out"
    
            @notification_setting.bind "click", ->
                if not self.config.notification
                    self.config.notification = true
                    self.notification_setting.removeClass "switch-off"
                    self.notification_setting.addClass "switch-on"
                else
                    self.config.notification = false
                    self.notification_setting.removeClass "switch-on"
                    self.notification_setting.addClass "switch-off"
                
                self.saveConfig()
    
        loadConfig: (callback, env)->
            self = this
    
            chrome.storage.sync.get "config", (val) ->
                if not val.config?
                    val.config = self.loadDefaultConfig
                if val.config.kbps not in ["64", "128", "192"]
                    val.config.kbps = "128"
    
                self.renderConfig val.config

                chrome.storage.sync.set { config: val.config }, ->

                    self.config = val.config
                    if callback?
                        callback.call(env, self.config)
    
        loadDefaultConfig:
            kbps: "128"
            channel: "0"
            notification: false
            lastfm: ""
    
        renderConfig: (config)->
            @kbps_setting.val config.kbps
    
            if config.notification
                @notification_setting.addClass "switch-on"
            else
                @notification_setting.addClass "switch-off"
    
            if config.lastfm?
                @lastfm_value.text config.lastfm.name
            else
                @lastfm_value.text "未绑定"
    
        saveConfig: (callback)->
            self = @
            chrome.storage.sync.set { config: @config }, ->
                if callback?
                    callback self.config
