local create_table
create_table = require("lapis.db.schema").create_table
return function(self)
  return create_table("categories", {
    {
      "id",
      "INTEGER PRIMARY KEY"
    },
    {
      "name",
      "TEXT"
    }
  })
end
