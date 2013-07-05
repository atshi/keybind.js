Keybind.js
==============

The goal of this project is to provide a library for creating keybindings with any webapp.

### Compile with: ###
    coffee --output js --compile coffeescript

### Usage: ###
This example listens to the shortcut a + d:

    var k = new Keybinding('ad', function(count) { console.log("Do action 'ad' " + count + " times") });

Methods available to the created Keybinding object are:

*    ``remove();`` - Remove keybinding
*    ``getShortcut();`` - Get shortcut sequence
*    ``getDescription();`` - Get description of shortcut
*    ``getAction();`` - Get reference to the function being called

And if you want to get all registered shortcuts in an array:

    var registered = Keybinding.getRegistered();
