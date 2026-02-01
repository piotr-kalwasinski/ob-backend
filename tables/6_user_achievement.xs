table user_achievement {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    timestamp achieved_at?
    int current_value?
    uuid user_id? {
      table = "user"
    }
  
    uuid achievement_id? {
      table = "achievement"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}