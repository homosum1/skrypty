lapis = require "lapis"

class App extends lapis.Application
  "/": =>
    json: message: "Hello world"

return App
