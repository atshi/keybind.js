# Author: atshi.com

class Keybinding
    constructor: (shortcut, action, description) ->
        @getShortcut = ->
            shortcut

        @getDescription = ->
            description

        @getAction = ->
            action

        KeybindingManager.init()
        KeybindingManager.registerShortcut shortcut
        KeybindingManager.registerAction @

    @getRegistered: ->
        registered = []
        for own key, collection of KeybindingManager.actions
            for keybinding in collection
                registered.push keybinding
        registered

class KeybindingManager
    @TIMEOUT = 300

    @shortcuts = []
    @actions = []
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
        for keybinding in @actions[sequence]
            keybinding.getAction().call(window, count, sequence, keybinding.getDescription())

    @sequenceActionExists: (sequence) ->
        @actions[sequence]? and @actions[sequence].length > 0

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

    @registerShortcut: (shortcut) ->
        array = @shortcuts
        for i in [0...shortcut.length]
            char = shortcut.charAt(i)
            if !array[char]?
                array[char] = []
            array = array[char]

    @registerAction: (keybinding) ->
        if !@actions[keybinding.getShortcut()]?
            @actions[keybinding.getShortcut()] = []
        @actions[keybinding.getShortcut()].push keybinding

window.Keybinding = Keybinding
