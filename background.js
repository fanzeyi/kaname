function openView(viewId, viewLoc) {
    var screenWidth = screen.availWidth;
    var screenHeight = screen.availHeight;
    var width = 300;
    var height = 340;
    var app;
    var config = {
        id: viewId, 
        bounds: {
            width: width,
            height: height, 
            left: Math.round((screenWidth - width)/2),
            top: Math.round((screenHeight - height)/2)
        }, 
        minWidth: width, 
        maxWidth: width, 
        minHeight: height, 
        maxHeight: height, 
    };

    if (navigator.appVersion.indexOf("Win") != -1) {
        // f**k Windows
        config.frame = 'chrome';
        config.resizable = false;
    }else if(navigator.appVersion.indexOf("Linux") != -1) {
        // dear Linux
        config.frame = 'chrome';
        config.resizable = true;
    }else{
        // lovely Mac
        config.frame = 'none';
        config.resizable = false;
    }
    app = chrome.app.window.create("views/" + viewLoc, config);
}

chrome.app.runtime.onLaunched.addListener(function() {
    var app;
    var token;

    function openPlayerOrLogin() {
        chrome.storage.sync.get("token", function(token) {
            if(token.token) {
                openView("player", "player-v2.html");
            }else{
                openView("login", "login.html");
            }
        });
    }

    openPlayerOrLogin();
});
