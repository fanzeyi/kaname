
openView = (viewId, viewLoc, callback) ->
    screenWidth = screen.availHeight
    screenHeight = screen.availHeight
    width = 300
    height = 340
    config = 
        id: viewId
        bounds:
            width: width
            height: height
            left: Math.round((screenWidth - width)/2)
            top: Math.round((screenHeight - height)/2)
        minWidth: width
        maxWidth: width
        minHeight: height
        maxHeight: height

    if navigator.appVersion.indexOf("Win") != -1
        config.frame = 'chrome'
        config.resizable = false
    else if navigator.appVersion.indexOf("Linux") != -1
        config.frame = 'chrome'
        config.resizable = true
    else
        config.frame = 'none'
        config.resizable = false

    app = chrome.app.window.create "views/" + viewLoc, config, (win) ->
        callback win

if typeof define isnt "undefined"
    define [], ()->
        return openView
else
    window.openView = openView
