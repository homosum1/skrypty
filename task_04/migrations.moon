import create_table from require "lapis.db.schema"

return =>
  create_table "categories", {
    { "id", "INTEGER PRIMARY KEY" }
    { "name", "TEXT" }
  }
