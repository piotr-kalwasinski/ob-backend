table user_favorite_categories {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    uuid? user_id? {
      table = "user"
    }
  
    uuid? category_id? {
      table = "category"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}