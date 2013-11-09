
define ['/coffee-dist/player-fm-playlist.js'], (FMPlaylist) ->

    class Playlist
        constructor: (@setting)->
            @_playlist = []
            @currentSong = undefined
    
        init_fm: (callback) ->
            self = this
    
            if self.fm?
                if callback?
                    callback self
                return
            
            chrome.storage.sync.get "token", (val) ->
                self.fm = new FMPlaylist val.token, self.setting
                
                if callback?
                    callback self
    
        getSong: (current, callback, refresh) ->
            self = this
    
            if refresh
                @_playlist.length = 0
    
            if @_playlist.length is 0
                @fm.loadPlayList current, (songlist) ->
                    self._playlist.push.apply self._playlist, songlist
                    if callback?
                        callback self._playlist.shift()
                return
            
            if @_playlist.length is 1
                @fm.loadPlayList current, (songlist) ->
                    self._playlist.push.apply self._playlist, songlist
            
            if callback?
                callback @_playlist.shift()
    
        skipPlaylist: (current, callback) ->
            self = this
    
            @fm.skipPlaylist current, (songlist) ->
                self._playlist = _.clone songlist
                if callback?
                    callback self
    
        likeSong: (current, callback) ->
            self = this
            @fm.likeSong current, (songlist) ->
                self._playlist = _.clone self._playlist, songlist
    
        unlikeSong: (current, callback) ->
            self = this
    
            @fm.unlikeSong current, (songlist) ->
                self._playlist = _.clone self._playlist, songlist
    
        blockSong: (current, callback) ->
            self = this
    
            @fm.blockSong current, (songlist) ->
                self._playlist = _.clone self._playlist, songlist
                if callback?
                    callback self
    
