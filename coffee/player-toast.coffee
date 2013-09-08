
define ["jquery"], ($) ->

    class Toast
        constructor: (@text, @duration = 2000) ->
            @toast = $("#js-toast")
    
        show: ()->
            @toast.text @text
            @toast.removeClass "toast-out"
            @toast.addClass "toast-in"
    
            self = this
    
            setTimeout ->
                self.toast.removeClass "toast-in"
                self.toast.addClass "toast-out"
            , @duration
