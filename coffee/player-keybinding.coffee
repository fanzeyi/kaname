
define ['mousetrap'], (Mousetrap) ->

    class KeyBinding

        constructor: (@player)->
    
        bindAll: ->
            self = this
    
            Mousetrap.bind "s", ->
                self.player.skipSong()
                return false
    
            Mousetrap.bind "d", ->
                self.player.blockSong()
                return false
    
            Mousetrap.bind "f", ->
                self.player.likingSong()
                return false
    
            Mousetrap.bind "space", ->
                self.player.playPauseSong()
                return false
