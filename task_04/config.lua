local config = require("lapis.config")
return config("development", function()
  local _ = {
    port = 8080
  }
  _ = {
    application = "app"
  }
  return {
    sqlite = {
      database = "dev.db"
    }
  }
end)
