function icrement_added_photo {
  input {
    uuid? user_id?
  }

  stack {
    db.get user_stat {
      field_name = "user_id"
      field_value = $input.user_id
    } as $user_stat1
  
    conditional {
      if ($user_stat1 == null) {
        db.add user_stat {
          data = {
            created_at            : "now"
            consecutive_days      : 0
            total_photos_described: 0
            total_photos_uploaded : 1
            max_weekly_photos     : 0
            last_activity_date    : ""
            user_id               : $input.user_id
            weekly_goal_record    : 0
            annotation_streak_days: 0
            streak_update         : now
          }
        } as $user_stat2
      }
    
      else {
        var $x1 {
          value = $user_stat1.total_photos_uploaded +1
        }
      
        db.edit user_stat {
          field_name = "user_id"
          field_value = $input.user_id
          data = {total_photos_uploaded: $x1}
        } as $user_stat3
      }
    }
  
    function.run icrement_team_added {
      input = {user_id: $input.user_id}
    } as $func1
  }

  response = "OK"
}