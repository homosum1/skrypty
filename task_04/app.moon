lapis = require "lapis"
import App from lapis.Application
import cat_routes from require "controllers.categories"

class App extends lapis.Application
  "/": =>
    json: message: "Hello world 4"

App\extend cat_routes

return App
