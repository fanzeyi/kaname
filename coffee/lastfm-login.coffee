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

    _api: (method, params, callback, action = "GET") ->
        params.api_key = @key
        params.method = method

        params.api_sig = @_sign params
        params.format = "json"
        
        $.ajax @api_base + "?" + $.param(params),
            type: action
            dataType: "json"
            success: (response)->
                if callback?
                    callback response
            #error:
                #chrome.app.window.current().close()

    login: (params, callback) ->
        @_api "auth.getMobileSession",
            username: params.username
            authToken: md5(params.username + md5(params.password))
        , callback, "POST"

$(document).ready ->
    lastfm = new LastFM '3a79de48b56292f6a6daa967cdec2ed2', '75428b69cec448a9cd4c9b504e719941'
    lastfm_form = $("#js-lastfm-form")
    lastfm_username = $("#js-lastfm-username")
    lastfm_password = $("#js-lastfm-password")

    lastfm_form.on "submit", ->
        username = lastfm_username.val()
        password = lastfm_password.val()

        lastfm.login
            username: username
            password: password
        , (response) ->
            console.log response
            chrome.storage.sync.set
                lastfm: response.session
            , (token)->
                console.log token
                chrome.app.window.current().close()
        
        return false
