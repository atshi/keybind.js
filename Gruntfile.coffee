module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        coffee:
            compile:
                files:
                    'keybind.js': 'coffeescript/keybind.coffee'

        uglify:
            build:
                options:
                    banner: grunt.file.read 'BANNER'
                files:
                    'keybind.min.js': 'keybind.js'

        'clean-pattern':
            scripts:
                path: './'
                pattern: /(keybind.js)/

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'clean-pattern'

    grunt.registerTask 'default', ['coffee']
    grunt.registerTask 'build', ['coffee', 'uglify', 'clean-pattern']