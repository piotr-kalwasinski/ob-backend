query user_stats verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    db.query user_stat {
      where = $db.user_stat.user_id == $auth.id
      return = {type: "single"}
    } as $user_stat1
  
    conditional {
      if ($user_stat1 == null) {
        db.add user_stat {
          data = {
            created_at            : "now"
            consecutive_days      : 0
            total_photos_described: 0
            total_photos_uploaded : 0
            max_weekly_photos     : 0
            last_activity_date    : ""
            user_id               : $auth.id
            weekly_goal_record    : 0
          }
        } as $user_stat1
      }
    }
  }

  response = {
    consecutive_days       : $user_stat1.annotation_streak_days
    top_weekly_descriptions: $user_stat1.weekly_goal_record
    added_pictures         : $user_stat1.total_photos_uploaded
    described_pictures     : $user_stat1.total_photos_described
  }

  tags = ["stat"]
}