lapis = require "lapis"

config = require "lapis.config"

config "development", ->
  port: 8080
  code_cache: "off"
