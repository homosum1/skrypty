local config = require("lapis.config")
return config("development", function()
  return {
    port = 8080
  }
end)
