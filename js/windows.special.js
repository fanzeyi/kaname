$(document).ready(function() {
    if(navigator.appVersion.indexOf("Win") != -1) {
        // f**k Windows
        var style = document.createElement("link");
        style.rel = "stylesheet";
        style.href = "/css/windows.css";
        $("head").append(style);
    }
});
