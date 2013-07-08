Keybind.js
==============

A lightweight library for creating keybindings in webapps.

### Compile with: ###
    grunt build

### Usage: ###
This example listens to the shortcut a + d:

    var k = new Keybinding('ad', function(count) { console.log("Do action 'ad' " + count + " times") });

Here we add a description for the keybinding:

    var action = function(count) { console.log("Do action 'ad' " + count + " times") };
    var k = new Keybinding('ad', action, 'Add dog');

You can also specify a 'mode' for keybindings:

    var k = new Keybinding('ad', action, 'Add dog', 'Insert Mode');

This will make that keybinding only execute actions if the global Keybinding object has the same mode set. This can be used to have different keybindings in different circumstances.

You can set and get current mode like this:

    Keybinding.setMode('Insert Mode');
    Keybinding.getMode();

Keybindings with no mode set will be global and always execute.

And if you want to get all registered shortcuts in an array:

    var registered = Keybinding.getRegistered();

Methods available to the created Keybinding object are:

*    ``remove();`` - Remove keybinding
*    ``getShortcut();`` - Get shortcut sequence
*    ``getDescription();`` - Get description of shortcut
*    ``getAction();`` - Get reference to the function being called

Methods available to the global Keybinding object are:

*    ``setMode();`` - Set keybinding mode
*    ``getMode();`` - Get keybinding mode
*    ``getRegistered();`` - Get registered keybindings
