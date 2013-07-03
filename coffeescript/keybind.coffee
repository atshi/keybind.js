# Author: atshi.com

class Keybinding
    @TIMEOUT = 300

    @shortcuts = []
    @actions = []
    @initiated = false
    @sequence = ''
    @prevSequence = ''
    @timeoutInterval = null

    constructor: (shortcut, action) ->
        Keybinding.init()
        Keybinding.registerShortcut shortcut
        Keybinding.registerAction shortcut, action

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

        if @timeoutInterval?
            clearTimeout @timeoutInterval
            @timeoutInterval = null

        # Start a new sequence with unused char
        if charFromPrev?
            @addToSequence charFromPrev

    @executeSequence: (sequence) ->
        for action in @actions[sequence]
            action.call(window, [1])

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

    @registerAction: (shortcut, action) ->
        if !@actions[shortcut]?
            @actions[shortcut] = []
        @actions[shortcut].push action

window.Keybinding = Keybinding
