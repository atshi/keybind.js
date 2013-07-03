Keybind.js
==============

The goal of this project is to provide a library for creating keybindings with any webapp.

### Compile with: ###
    coffee --output js --compile coffeescript

### Usage: ###
This example listens to the shortcut a + d:

    new Keybinding('ad', function(count) { console.log("Do action 'ad' " + count + " times") });
