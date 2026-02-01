// Available picture categories.
table category {
  auth = false

  schema {
    uuid id
  
    // The name of the category.
    text name filters=trim
  
    int akty_bielik_id?
    text description? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "name", op: "asc"}]}
  ]

  tags = ["category"]
}