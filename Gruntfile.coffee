module.exports = (grunt) ->
  grunt.registerTask "prepublish", ->
    done = @async()
    exec = require("child_process").exec
    exec "coffee -c -o lib/ src/", done
