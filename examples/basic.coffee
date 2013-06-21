tp = require "../lib/tidy-prompt"

tp.start()
tp.log "Hello, tidy prompt!"

tp.on "input", (data) ->
  tp.log "You typed: #{data}"

tp.on "SIGINT", ->
  tp.log "Bye!"
  process.exit 0
