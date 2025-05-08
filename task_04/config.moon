config = require "lapis.config"

config "development", ->
  port: 8080
  application: "app"
  sqlite: {
    database: "dev.db"
  }