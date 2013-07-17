class Keybinding
    constructor: (shortcut, action, description, mode) ->
        sequence = shortcut.toUpperCase().match /(?:<.+>|.)\+.|<.+>|./g
        rules = []

        for part, i in sequence
            split = part.split '+'
            if split.length > 1
                rules[i] = split[0]
                sequence[i] = split[1]

        @getRule = (index) ->
            rules[index]

        @getSequence = ->
            sequence

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
