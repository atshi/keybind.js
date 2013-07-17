class KeybindingManager
    @TIMEOUT = 300

    @keybindings = []
    @globalkeybindings = []
    @modevalues = []
    @initiated = false
    @storedCount = ''
    @timeoutInterval = null
    @mode = null
    @keysDown = []
    @currentMatches = null

    @Keys =
        TAB: 9
        SHIFT: 16
        CTRL: 17
        ALT: 18
        CAPS_LOCK: 20
        ESCAPE: 27
        CMD_LEFT: 91
        CMD_RIGHT: 93
        ZERO: '0'.charCodeAt(0)
        NINE: '9'.charCodeAt(0)

    @modifiers =
        '<TAB>': @Keys.TAB
        '<SHIFT>': @Keys.SHIFT
        '<S>': @Keys.SHIFT
        '<CTRL>': @Keys.CTRL
        '<C>': @Keys.CTRL
        '<ALT>': @Keys.ALT
        '<CAPS_LOCK>': @Keys.CAPS_LOCK
        '<CAPSLOCK>': @Keys.CAPS_LOCK
        '<ESCAPE>': @Keys.ESCAPE
        '<ESC>': @Keys.ESCAPE
        '<CMD_LEFT>': @Keys.CMD_LEFT
        '<CMDLEFT>': @Keys.CMD_LEFT
        '<CMDL>': @Keys.CMD_LEFT
        '<CMD_RIGHT>': @Keys.CMD_RIGHT
        '<CMDRIGHT>': @Keys.CMD_RIGHT
        '<CMDR>': @Keys.CMD_RIGHT

    @init: ->
        if !@initiated
            @initiated = true

            # Setup reversed modifiers
            @reversedModifiers = []
            for own key, value of @modifiers
                Utils.safePush @reversedModifiers, value, key

            if document.attachEvent # Internet Explorer
                document.attachEvent 'onkeyup', -> @onKeyUp
                document.attachEvent 'onkeydown', -> @onKeyDown
            else if document.addEventListener
                document.addEventListener 'keyup', @onKeyUp, false
                document.addEventListener 'keydown', @onKeyDown, false

    @setMode: (mode) ->
        @mode = mode
        @updateKeybindings()

    @getMode: ->
        @mode

    @getKeybindings: ->
        keybindings = Utils.cloneObject @globalkeybindings

        for own key, value of @modevalues
            Utils.mergeInto @modevalues[key], keybindings

        keybindings

    @getCurrentKeybindings: ->
        @keybindings

    @updateKeybindings: ->
        @keybindings = Utils.cloneObject @globalkeybindings

        if @mode and @modevalues[@mode]?
            Utils.mergeInto @modevalues[@mode], @keybindings

    @onKeyUp: (ev) =>
        delete @keysDown[ev.keyCode]

    @onKeyDown: (ev) =>
        @keysDown[ev.keyCode] = true
        @addToSequence ev.keyCode

    @tryRule: (rule) ->
        if rule
            keycodes = @getKeycodes rule
            for key in keycodes
                if @keysDown[key]? and @keysDown[key]
                    return true
            return false
        true

    @getKeycodes: (char) ->
        if @modifiers[char]?
            [@modifiers[char]]
        else
            [char.charCodeAt 0]

    @getChars: (keycode) ->
        if @reversedModifiers[keycode]?
            @reversedModifiers[keycode]
        else
            [String.fromCharCode keycode]

    @addToSequence: (keycode) ->
        if @timeoutInterval?
            clearTimeout @timeoutInterval
            @timeoutInterval = null

        if !@currentMatches? and keycode >= @Keys.ZERO and keycode <= @Keys.NINE
            @storedCount += String.fromCharCode(keycode)
        else
            if !@currentMatches?
                @currentMatches = @keybindings
                @matchIndex = 0

            chars = @getChars keycode
            newMatches = []
            exactMatches = []
            foundNewMatches = false
            @matchIndex++

            for char in chars
                for own key, keybinding of @currentMatches[char]
                    sequence = keybinding.getSequence()
                    if sequence.length > @matchIndex
                        if @tryRule keybinding.getRule(@matchIndex)
                            nextChar = sequence[@matchIndex]
                            Utils.safePush newMatches, nextChar, keybinding
                            foundNewMatches = true
                    else
                        if @tryRule keybinding.getRule(@matchIndex - 1)
                            exactMatches.push keybinding

            if !foundNewMatches
                @currentMatches = null
                if exactMatches.length > 0
                    @executeMatches exactMatches
                else if @currentExactMatches? and @currentExactMatches.length > 0
                    @executeMatches @currentExactMatches
                    @addToSequence keycode
                else
                    @currentExactMatches = null
            else
                @currentMatches = newMatches

                @currentExactMatches = exactMatches
                @timeoutInterval = setTimeout @executeMatches.bind(this, @currentExactMatches), @TIMEOUT

    @executeMatches: (matches) ->
        count = Math.max(1, parseInt(@storedCount))
        @storedCount = ''
        if !count then count = 1
        if matches?
            for keybinding in matches
                keybinding.getAction().call(window, count, keybinding.getShortcut(), keybinding.getDescription())

        if @timeoutInterval?
            clearTimeout @timeoutInterval
            @timeoutInterval = null

        @currentExactMatches = null
        @currentMatches = null

    @register: (keybinding) ->
        if keybinding.getMode()
            keybindings = Utils.getAndCreate @modevalues, keybinding.getMode()
        else
            keybindings = @globalkeybindings
        sequence = keybinding.getSequence()

        if sequence.length > 0
            Utils.safePush keybindings, sequence[0], keybinding

        @updateKeybindings()

    @unregister: (keybinding) ->
        if keybinding.getMode()
            keybindings = @modevalues[keybinding.getMode()]
        else
            keybindings = @globalkeybindings

        sequence = keybinding.getSequence()
        first = sequence[0]
        index = keybindings[first].indexOf keybinding
        keybindings[first].splice index, 1

        @updateKeybindings()
