query user_weekly_goal verb=POST {
  api_group = "Achievements"
  auth = "user"

  input {
    uuid? weekly_goal?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    function.run get_monday {
      input = {current_time: now, timezone: ""}
    } as $monday
  
    function.run add_seven_days {
      input = {input_date: $monday}
    } as $sunday
  
    db.add user_weekly_goal {
      data = {
        created_at      : "now"
        start_date      : now
        photos_described: 0
        completed       : false
        user_id         : $auth.id
        weekly_goal_id  : $input.weekly_goal
        start_of_week   : $monday
        end_of_the_week : $sunday
      }
    } as $user_weekly_goal1
  }

  response = "OK"
}