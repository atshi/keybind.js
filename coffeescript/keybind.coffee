class Keybinding
    constructor: (shortcut, action, description) ->
        @getShortcut = ->
            shortcut

        @getDescription = ->
            description

        @getAction = ->
            action

        KeybindingManager.init()
        KeybindingManager.register @

    remove: ->
        KeybindingManager.unregister @

    @getRegistered: ->
        registered = []
        for own key, collection of KeybindingManager.keybindings
            for keybinding in collection
                registered.push keybinding
        registered

class KeybindingManager
    @TIMEOUT = 300

    @shortcuts = []
    @keybindings = []
    @initiated = false
    @sequence = ''
    @prevSequence = ''
    @storedCount = ''
    @timeoutInterval = null

    @Keys =
        ZERO: '0'.charCodeAt(0)
        NINE: '9'.charCodeAt(0)

    @init: ->
        if !@initiated
            @initiated = true

            if document.attachEvent # Internet Explorer
                document.attachEvent 'onkeypress', -> @onKeyPress
            else if document.addEventListener
                document.addEventListener 'keypress', @onKeyPress, false

    @onKeyPress: (ev) =>
        @addToSequence String.fromCharCode(ev.charCode)

    @addToSequence: (char) ->
        if @timeoutInterval?
            clearTimeout @timeoutInterval
            @timeoutInterval = null

        charcode = char.charCodeAt(0)

        if !@sequence and charcode >= @Keys.ZERO and charcode <= @Keys.NINE
            @storedCount += char
        else
            @prevSequence = @sequence
            @sequence += char
            if @sequenceHasChildren @sequence
                @timeoutInterval = setTimeout @findSequenceAndExecute.bind(this), @TIMEOUT
            else
                @findSequenceAndExecute()

    @findSequenceAndExecute: ->
        if @sequenceActionExists @sequence
            @executeSequence @sequence
            charFromPrev = null
        else if @sequenceActionExists @prevSequence
            @executeSequence @prevSequence
            charFromPrev = @sequence.slice(-1)

        @sequence = ''
        @prevSequence = ''
        @storedCount = ''

        if @timeoutInterval?
            clearTimeout @timeoutInterval
            @timeoutInterval = null

        # Start a new sequence with unused char
        if charFromPrev?
            @addToSequence charFromPrev

    @executeSequence: (sequence) ->
        count = Math.max(1, parseInt(@storedCount))
        if !count then count = 1
        for keybinding in @keybindings[sequence]
            keybinding.getAction().call(window, count, sequence, keybinding.getDescription())

    @sequenceActionExists: (sequence) ->
        @keybindings[sequence]? and @keybindings[sequence].length > 0

    @sequenceHasChildren: (sequence) ->
        array = @shortcuts
        for i in [0...sequence.length]
            char = sequence.charAt(i)
            if !array[char]?
                return false
            array = array[char]
        for own key of array
            return true
        return false

    @removeLastInSequence: (sequence) ->
        array = @shortcuts
        for i in [0...sequence.length]
            char = sequence.charAt(i)
            if i == sequence.length-1
                delete array[char]
            if !array[char]?
                return
            array = array[char]

    @register: (keybinding) ->
        if !@keybindings[keybinding.getShortcut()]?
            @keybindings[keybinding.getShortcut()] = []
        @keybindings[keybinding.getShortcut()].push keybinding

        # Register shortcut
        array = @shortcuts
        shortcut = keybinding.getShortcut()
        for i in [0...shortcut.length]
            char = shortcut.charAt(i)
            if !array[char]?
                array[char] = []
            array = array[char]

    @unregister: (keybinding) ->
        shortcut = keybinding.getShortcut()
        index = @keybindings[shortcut].indexOf keybinding
        @keybindings[shortcut].splice index, 1

        # Remove from shortcuts
        sequence = shortcut
        while !@sequenceHasChildren(sequence) and sequence.length > 0 and (!@keybindings[sequence]? or @keybindings[sequence].length == 0)
            @removeLastInSequence sequence
            sequence = sequence.slice 0, -1

window.Keybinding = Keybinding
