
define ['mousetrap'], (Mousetrap) ->

    class KeyBinding

        constructor: (@player)->
    
        bindAll: ->
            self = this
    
            Mousetrap.bind "s", ->
                self.player.skipSong()
    
            Mousetrap.bind "d", ->
                self.player.blockSong()
    
            Mousetrap.bind "f", ->
                self.player.likingSong()
    
            Mousetrap.bind "space", ->
                self.player.playPauseSong()
