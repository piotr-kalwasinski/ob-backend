table user_stat {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    int consecutive_days?
    int total_photos_described?
    int total_photos_uploaded?
    int max_weekly_photos?
    timestamp last_activity_date?
    uuid user_id? {
      table = "user"
    }
  
    int weekly_goal_record?
  
    // liczba dni ile z rzedu z opisami od usera
    int annotation_streak_days?
  
    timestamp? streak_update?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}