table login_history {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    object auth? {
      schema
    }
  
    text sub? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}