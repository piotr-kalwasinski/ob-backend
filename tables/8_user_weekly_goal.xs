table user_weekly_goal {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    timestamp start_date?
    int photos_described?
    bool completed?
    uuid user_id? {
      table = "user"
    }
  
    uuid weekly_goal_id? {
      table = "weekly_goal"
    }
  
    // Poniedzialek w ktorym zaczeto wyzwanie
    timestamp? start_of_week?
  
    // Niedziele kiedy konczy sie wyzwanie
    timestamp? end_of_the_week?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}