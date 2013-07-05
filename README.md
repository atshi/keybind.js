Keybind.js
==============

The goal of this project is to provide a library for creating keybindings with any webapp.

### Compile with: ###
    grunt build

### Usage: ###
This example listens to the shortcut a + d:

    var k = new Keybinding('ad', function(count) { console.log("Do action 'ad' " + count + " times") });

Here we add a description for the keybinding:

    var action = function(count) { console.log("Do action 'ad' " + count + " times") };
    var k = new Keybinding('ad', action, 'Add dog');

And if you want to get all registered shortcuts in an array:

    var registered = Keybinding.getRegistered();

Methods available to the created Keybinding object are:

*    ``remove();`` - Remove keybinding
*    ``getShortcut();`` - Get shortcut sequence
*    ``getDescription();`` - Get description of shortcut
*    ``getAction();`` - Get reference to the function being called
