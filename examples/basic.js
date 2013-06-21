var tp;

tp = require("../lib/tidy-prompt");

tp.start();

tp.log("Hello, tidy prompt!");

tp.on("input", function(data) {
  return tp.log("You typed: " + data);
});

tp.on("SIGINT", function() {
  tp.log("Bye!");
  return process.exit(0);
});
