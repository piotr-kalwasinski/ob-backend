query user_weekly_record verb=GET {
  api_group = "Achievements"
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
  
    db.get user_stat {
      field_name = "user_id"
      field_value = $auth.id
    } as $user_stat1
  
    conditional {
      if ($user_stat1 == null) {
        var $x1 {
          value = 0
        }
      }
    
      else {
        var $x1 {
          value = $user_stat1.weekly_goal_record
        }
      }
    }
  }

  response = $x1
}