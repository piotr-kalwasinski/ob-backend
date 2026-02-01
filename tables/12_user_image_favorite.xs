table user_image_favorite {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    uuid? image_id?
    bool is_favorite?
    text external_image_id? filters=trim
    uuid? user_id? {
      table = "user"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}