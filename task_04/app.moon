lapis = require "lapis"

class App extends lapis.Application
  "/": =>
    json: message: "Hello world 3"

return App
