// Pomysly na rozwoj od usera
table ideas {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    uuid? user_id? {
      table = "user"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}