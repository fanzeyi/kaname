chrome.app.runtime.onLaunched.addListener(function() {
    var screenWidth = screen.availWidth;
    var screenHeight = screen.availHeight;
    var width = 300;
    var height = 340;
    var app;
    var token;
    var viewLocation, viewId;
    var frame;

    function openPlayerOrLogin() {
        chrome.storage.sync.get("token", function(token) {
            if(token.token) {
                viewLocation = "player-v2.html";
                viewId = "player";
            }else{
                viewLocation = "login.html";
                viewId = "login";
            }
            if (navigator.appVersion.indexOf("Win") != -1) {
                // f**k Windows
                frame = 'chrome';
            }else{
                frame = 'none';
            }
            app = chrome.app.window.create("views/" + viewLocation, {
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
                resizable: false, 
                frame: frame
            });
        });
    }

    openPlayerOrLogin();
});
