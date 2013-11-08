
define ["jquery"], ($) ->

    class LastFM
        api_base: "http://ws.audioscrobbler.com/2.0/"
    
        constructor: (@key, @secret) ->
    
        _sign: (params) ->
            keys = []
            string = ""
    
            for key of params
                keys.push key
    
            keys.sort()
    
            for key in keys
                string += key + params[key]
    
            string += @secret
    
            md5 string
    
        _api: (method, params, callback, action = "get") ->
            params.api_key = @key
            params.method = method
    
            params.api_sig = @_sign params
            params.format = "json"
    
            if action.toLowerCase() is "get"
                $.get @api_base + "?" + $.param(params), (response) ->
                    if callback?
                        callback response
            else
                $.post @api_base, params, (response) ->
                    if callback?
                        callback response
    
        login: (params, callback) ->
            @_api "auth.getMobileSession",
                username: params.username
                authToken: md5(params.username + md5(params.password))
            , callback, "POST"

        ban: (params, callback)->
            @_api "track.ban",
                track: params.track
                artist: params.artist
            , callback, "POST"

        love: (params, callback)->
            @_api "track.love",
                track: params.track
                artist: params.artist
                sk: params.sk
            , callback, "POST"

        unlove: (params, callback)->
            @_api "track.unlove",
                track: params.track
                artist: params.artist
                sk: params.sk
            , callback, "POST"    

        updateNowPlaying: (params, callback)->
            @_api "track.updateNowPlaying",
                artist: params.artist
                track: params.track
                album: params.album
                duration: params.duration
                sk: params.sk
            , callback, "POST"
    
        scrobbble: (params, callback) ->
            @_api "track.scrobble", params, callback, "POST"
