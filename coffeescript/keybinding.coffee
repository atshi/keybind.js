class Keybinding
    constructor: (shortcut, action, description, mode) ->
        @getShortcut = ->
            shortcut

        @getDescription = ->
            description

        @getAction = ->
            action

        @getMode = ->
            mode

        KeybindingManager.init()
        KeybindingManager.register @

    remove: ->
        KeybindingManager.unregister @

    @setMode: (mode) ->
        KeybindingManager.setMode mode

    @getMode: (mode) ->
        KeybindingManager.getMode()

    @getRegistered: ->
        registered = []
        for own key, collection of KeybindingManager.getKeybindings()
            for keybinding in collection
                registered.push keybinding
        registered

window.Keybinding = Keybinding
