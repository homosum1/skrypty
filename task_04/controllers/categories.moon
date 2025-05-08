import respond_to from require "lapis.application"
import Category from require "models.category"

categories = {
  { id: 1, name: "fruits" }
  { id: 2, name: "vegetables" }
  { id: 3, name: "candies" }
}

return {
  "/categories": respond_to {
    GET: => json: categories
    POST: =>
      new_id = #categories + 1
      table.insert categories, {
        id: new_id
        name: @params.name
      }
      status: 201
      json: message: "Category created!"
  },

  "/categories/:id": respond_to {
    GET: =>
      id = tonumber @params.id
      cat = categories[id]
      if cat then
        json: cat
      else
        status: 404
        json: error: "Not found"

    PUT: =>
      id = tonumber @params.id
      cat = categories[id]
      if cat then
        cat.name = @params.name or cat.name
        json: message: "Updated"
      else
        status: 404
        json: error: "Not found"

    DELETE: =>
      id = tonumber @params.id
      if categories[id] then
        categories[id] = nil
        json: message: "Deleted"
      else
        status: 404
        json: error: "Not found"
  }
}
