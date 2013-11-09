
define ['jquery',
        '/coffee-dist/player-playlist.js',
        '/coffee-dist/player-fm-channel.js',
        '/coffee-dist/player-fm-share.js',
        '/coffee-dist/player-toast.js'], ($, Playlist, FMChannel, FMShare, Toast) ->

    class Player
        constructor: (@setting)->
            self = this
            @$ = $("#js-player")
            @_ = @$[0]
            @cover = $("#js-cover")
            @album = $("#js-album")
            @songName = $("#js-songName")
            @artist = $("#js-artist")
            @leftTime = $("#js-leftTime")
            @card = $("#js-card")
            @share = $("#js-share")
            @share_panel = $("#js-share-panel")
            @share_input = $("#js-share input")
            @playlist = new Playlist(@setting)
    
            chrome.storage.sync.get "token", (val) ->
                self.channel = new FMChannel(val.token, self.setting)
                self.channel.loadList (list) ->
                    self.initList list
    
            @skip_button = $("#js-skip")
            @like_button = $("#js-love")
            @trash_button = $("#js-trash")
            @play_button = $("#js-play")
            @channel_button = $("#js-channel")
            
            @channel_panel = $("#js-channel-panel")
            @channel_list  = $("#js-channel-list")
            @channel_search_form = $("#js-channel-search-form")
            @channel_search_kw = $("#js-channel-search-kw")
    
            @setting_button = $("#js-setting")
            @setting_panel = $("#js-setting-panel")
    
            @share_content = $("#js-share-content")
            @share_cancel_button = $("#js-share-cancel")
            @share_submit_button = $("#js-share-submit")

            @panels = $(".js-panel")
            @panel_down = false
    
            @$.bind 'ended', ->
                self.finishPlay()
    
            @skip_button.bind "click", ->
                self.skipSong()
    
            @like_button.bind "click", ->
                self.likingSong()
    
            @trash_button.bind "click", ->
                self.blockSong()
    
            @play_button.bind "click", ->
                self.playPauseSong()
    
            @channel_button.bind "click", ->
                if self.channel_panel.hasClass "show"
                    self.channel_panel.removeClass "show"
                    self.channel_panel.addClass "remove"
                    self.panel_down = false
                else
                    self.resetPanel()
                    self.channel_panel.removeClass "remove"
                    self.channel_panel.addClass "show"
                    self.panel_down = true
    
            @setting_button.bind "click", ->
                if self.setting_panel.hasClass "show"
                    self.setting_panel.removeClass "show"
                    self.setting_panel.addClass "remove"
                    self.panel_down = false
                else
                    self.resetPanel()
                    self.setting_panel.removeClass "remove"
                    self.setting_panel.addClass "show"
                    self.panel_down = true
    
            setInterval ->
                if not self.current?
                    self.leftTime.text ""
                else
                    leftTime = Math.floor self._.duration - self._.currentTime
                    if isNaN(leftTime)
                        self.leftTime.text ""
                        return
                    second = leftTime % 60
                    minute = Math.floor leftTime / 60
                    if second < 10
                        second = "0" + second
                    self.leftTime.text "-" + minute + ":" + second
    
                    if self.current.scrobbbled?
                        return
                    
                    if self._.currentTime >= (self._.duration * 0.5)
                        self.current.scrobbbled = true
                        self.setting.lastfm.scrobbble
                            artist: self.current.artist
                            track: self.current.title
                            album: self.current.albumtitle
                            timestamp: self.current.timestamp
                            sk: self.setting.config.lastfm.key
            , 200
    
            @share.bind "click", ->
                if self.card.hasClass "show-back"
                    if self.panel_down
                        self.resetPanel()
                        return
                    self.card.removeClass "show-back"
                else if self.current?
                    self.resetPanel()
                    self.card.addClass "show-back"
    
            @share_cancel_button.bind "click", ->
                self.card.removeClass "show-back"
    
            @share_submit_button.bind "click", ->
                content = self.share_content.val()

                FMShare self.current, content, self.setting.config, self.channel_name, self.channel.token.access_token, ->
                    self.share_content.val ""
        
                    toast = new Toast("分享成功")
                    toast.show()
                , ->
                    toast = new Toast("分享失败")
                    toast.show()
    
                self.card.removeClass "show-back"

            chrome.notifications.onButtonClicked.addListener (notID, ibtn) ->
                switch ibtn
                    when 0 then self.skipSong true
                    when 1 
                        song = JSON.parse(notID)
                        if self.current.ssid == song.ssid
                            self.blockSong true
                        else
                            self.playlist.blockSong song, (playlist) ->

            @album.on "click", ->
                if self.setting.config.albumdoubanmusic
                    window.open "http://music.douban.com" + self.current.album

            @channel_list.on "click", ".js-channel", ->
                $this = $(@)
                self.channel_name = $this.text()
                self.setting.config.channel = $this.parent().data("cid") + ""
                self.setting.saveConfig()
                self.restartPlay()
    
                $(".nowplaying").remove()
                $this.parent().append '<i class="nowplaying"></i>'
            
            @channel_search_form.on "submit", ->
                kw = self.channel_search_kw.val()

                if kw is ""
                    self.channel.loadList (list) ->
                        self.initList list
                    return false

                self.channel.search_channel kw, (list)-> 
                    self.channel_list.children().slice(1).remove()

                    _.each list.chls, (channel) ->
                        self.channel_list.append(self.renderChannel channel)

                return false
    
        resetPanel: ->
            @panel_down = false
            @panels.each (idx, panel) ->
                $panel = $(panel)
                if $panel.hasClass "show"
                    $panel.removeClass "show"
                    $panel.addClass "remove"
    
        playPauseSong: ()->
            if @_.paused
                @play()
            else
                @pause()
    
        restartPlay: ->
            self = this
    
            @playlist.getSong undefined, (song) ->
                self.playSong song
            , true
    
        startPlay: ->
            self = this
            
            @playlist.init_fm (playlist) ->
                playlist.getSong self.current, (song) ->
                    self.playSong song
    
        playSong: (song, notify = true) ->
            @current = song
            @_.src = song.url
            @loadCover song, notify
            @songName.text song.title
            @artist.text song.artist
            @like_button.removeClass()
    
            if song.like
                @like_button.addClass("dislike-button")
            else
                @like_button.addClass("like-button")
    
            if @setting.config.lastfm
                @setting.lastfm.updateNowPlaying
                    artist: song.artist
                    track: song.title
                    album: song.albumtitle
                    duration: song.length
                    sk: @setting.config.lastfm.key
    
            @current.timestamp = Math.floor((new Date()).getTime() / 1000)
    
            @play()
    
        finishPlay: ->
            self = this
    
            @current.currentTime = @_.currentTime
            @playlist.fm.finishPlaySong @current
            @playlist.getSong @current, (song) ->
                self.playSong song
    
        likingSong: ->
            if @current.like
                @dislikeSong()
            else
                @likeSong()
    
        skipSong: (notify = false)->
            self = this
    
            @current.currentTime = @_.currentTime
            @playlist.skipPlaylist @current, (playlist) ->
                playlist.getSong self.current, (song) ->
                    self.playSong song, notify
    
        likeSong: ->
            self = this
    
            @current.like = 1
            @current.currentTime = @_.currentTime
            @like_button.removeClass()
            @like_button.addClass("dislike-button")
            @playlist.likeSong @current

            if @setting.config.lastfm
                @setting.lastfm.love
                    track: @current.title
                    artist: @current.artist
                    sk: @setting.config.lastfm.key
    
        dislikeSong: ->
            self = this
    
            @current.like = 0
            @current.currentTime = @_.currentTime
            @like_button.removeClass()
            @like_button.addClass("like-button")
            @playlist.likeSong @current

            if @setting.config.lastfm
                @setting.lastfm.unlove
                    track: @current.title
                    artist: @current.artist
                    sk: @setting.config.lastfm.key
    
        blockSong: (notify = false)->
            self = this
    
            @current.currentTime = @_.currentTime
            @pause()
            @playlist.blockSong @current, (playlist) ->
                playlist.getSong undefined, (song) ->
                    self.playSong song, notify
                    self.playSong song

            if @setting.config.lastfm
                @setting.lastfm.ban
                    track: @current.title
                    artist: @current.artist
                    sk: @setting.config.lastfm.key
    
        pause: ->
            @play_button.removeClass "pause-button"
            @play_button.addClass "play-button"
            @_.pause()
    
        play: ->
            @play_button.removeClass "play-button"
            @play_button.addClass "pause-button"
            @_.play()

        sendNotification: (song, cover)->
            notifications = chrome.notifications.create JSON.stringify(song),
                type: "basic"
                title: song.title
                message: song.artist
                iconUrl: cover
                buttons: [
                    {
                        title: "下一首",
                        iconUrl: "/img/icon2/Next-notification.png"
                    },
                    {
                        title: "不再播放",
                        iconUrl: "/img/icon2/Trash-notification.png"
                    }
                ]
                
                , (notify) ->

        loadCover: (song, notify) ->
            self = this
            xhr = new XMLHttpRequest()
            xhr.open 'GET', song.picture.replace("mpic", "lpic"), true
            xhr.responseType = 'blob'
            xhr.onload = (e) ->
                if self.current.sid isnt song.sid
                    return
    
                img = new Image
                img.src = window.webkitURL.createObjectURL @response
                self.cover.empty()
                self.cover.append img
    
                if self.setting.config.notification and notify
                    self.sendNotification song, window.webkitURL.createObjectURL(@response)
    
            xhr.send()

        renderChannel: (channel) ->
            if channel.id in [0, -3]
                channel.name = channel.name + "兆赫"
            else
                channel.name = channel.name + " MHz"

            if channel.collected is "true"
                love = '<i class="star unstar js-unstar"></i>'
            else if channel.collected is "false"
                love = '<i class="star js-star"></i>'
            else
                love = ''
            
            if @setting.config.channel is channel.id + ""
                @channel_name = channel.name
                channel.name = channel.name + '<i class="nowplaying"></i>'

            return '<li class="channel" data-cid="' + channel.id + '"><div class="channel-change clickable js-channel"></div>' + love + channel.name + '</li>'
        
        initList: (list)->
            self = this

            @channel_list.children().slice(1).remove()

            _.each list.groups, (group)->
                @channel_list.append '<li class="group-name">' + group.group_name + '</li>'
    
                _.each group.chls, (channel)->
                    @channel_list.append(@renderChannel channel) 
                , @
            , @

            @channel_list.on "click", ".js-star", ->
                $this = $(this)
                cid = $(this).parent().data("cid")
                self.channel.collect_channel cid, ->
                    $this.removeClass "js-star"
                    $this.addClass "unstar js-unstar"

            @channel_list.on "click", ".js-unstar", ->
                $this = $(this)
                cid = $(this).parent().data("cid")
                self.channel.uncollect_channel cid, ->
                    $this.removeClass "unstar js-unstar"
                    $this.addClass "js-star"
