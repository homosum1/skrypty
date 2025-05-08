local respond_to
respond_to = require("lapis.application").respond_to
local Category
Category = require("models.category").Category
local categories = {
  {
    id = 1,
    name = "fruits"
  },
  {
    id = 2,
    name = "vegetables"
  },
  {
    id = 3,
    name = "candies"
  }
}
return {
  ["/categories"] = respond_to({
    GET = function(self)
      return {
        json = categories
      }
    end,
    POST = function(self)
      local new_id = #categories + 1
      table.insert(categories, {
        id = new_id,
        name = self.params.name
      })
      local _ = {
        status = 201
      }
      return {
        json = {
          message = "Category created!"
        }
      }
    end
  }),
  ["/categories/:id"] = respond_to({
    GET = function(self)
      local id = tonumber(self.params.id)
      local cat = categories[id]
      if cat then
        return {
          json = cat
        }
      else
        local _ = {
          status = 404
        }
        return {
          json = {
            error = "Not found"
          }
        }
      end
    end,
    PUT = function(self)
      local id = tonumber(self.params.id)
      local cat = categories[id]
      if cat then
        cat.name = self.params.name or cat.name
        return {
          json = {
            message = "Updated"
          }
        }
      else
        local _ = {
          status = 404
        }
        return {
          json = {
            error = "Not found"
          }
        }
      end
    end,
    DELETE = function(self)
      local id = tonumber(self.params.id)
      if categories[id] then
        categories[id] = nil
        return {
          json = {
            message = "Deleted"
          }
        }
      else
        local _ = {
          status = 404
        }
        return {
          json = {
            error = "Not found"
          }
        }
      end
    end
  })
}
