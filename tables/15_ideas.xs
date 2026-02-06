// Pomysly na rozwoj od usera
table ideas {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    uuid? user_id? {
      table = "user"
    }
  
    text idea? filters=trim|max:1000
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}