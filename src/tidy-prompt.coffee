EventEmitter = require("events").EventEmitter

# @TODO expose some sort of 'loading' mutable property
# where no input is received

prompt      = "=> "
inPrompt    = "<= "
currentLine = ""
esc         = "\u001B"
csi         = "#{esc}["
emitter     = new EventEmitter
options     = {}

doPrompt = -> process.stdout.write prompt+currentLine

write = (data) -> process.stdout.write data

writeLine = (data, prefix = "") ->
  # clear what we've currently got on the last line
  # [2K = clear line
  # [(n)D = move (n) characters left
  process.stdout.write "#{csi}2K#{csi}100D"

  # add the data for the new line
  process.stdout.write prefix+data+"\n"

  # if we're writing the current line, get rid of it
  currentLine = "" if data is currentLine

  # restore the contents of the current line & prompt
  doPrompt()

  return data

hasDataListener = false
emitter.on "newListener", (event, fn) ->
  if event is "data"
    throw "Only one data listener allowed" if hasDataListener
    hasDataListener = true

process.stdin.on "data", (char) ->
  if hasDataListener
    emitter.emit "data", char, processChar
  else
    processChar char

processChar = (char) ->
  switch char
    when "\r"

      if options.trapLine
        cb = (data) ->
          currentLine = data
          writeLine currentLine, inPrompt

        emitter.emit "input", currentLine, cb
      else
        emitter.emit "input", writeLine(currentLine, inPrompt)

    when "\u0003"
      # CTRL+C
      emitter.emit "SIGINT"

    when "\u0008", "\x7f"
      # backspace
      # move one char left (1D), delete from cursor to end of line (0K)
      process.stdout.write "#{csi}1D#{csi}0K"

      currentLine = currentLine.substr 0, currentLine.length-1

    when "#{csi}A", "#{csi}B", "#{csi}C", "#{csi}D" then
      # up, down, forward (right), back (left) arrows
      # no-op, for now

    else
      currentLine += char
      write char

module.exports =
  start: (_options = {}) ->
    # hook up stdin
    process.stdin.resume()
    process.stdin.setEncoding "utf8"
    process.stdin.setRawMode true

    options = _options

    doPrompt()

  write: write

  log: writeLine

  on: (message, callback) -> emitter.on message, callback

  setPrompt: (_prompt) ->
    prompt = _prompt

  setInPrompt: (_prompt) ->
    inPrompt = _prompt

  prompt: (line, callback) ->
    writeLine line
    emitter.once "input", callback

  clearLine: ->
    currentLine = ""
    process.stdout.write "#{csi}2K#{csi}100D#{prompt}"
