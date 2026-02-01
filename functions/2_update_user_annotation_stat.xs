// Tworzenie lub aktualizacja licznikow statystyk usera
function updateUserAnnotationStat {
  input {
    uuid? user_id?
  }

  stack {
    function.run get_monday {
      input = {current_time: now, timezone: "UTC"}
    } as $func1
  
    function.run add_seven_days {
      input = {current_time: now}
    } as $func2
  
    db.query user_weekly_goal {
      where = $db.user_weekly_goal.user_id == $input.user_id && $db.user_weekly_goal.start_of_week == $func1 && $db.user_weekly_goal.end_of_the_week == $func2
      sort = {user_weekly_goal.created_at: "desc"}
      return = {type: "single"}
    } as $user_weekly_goal1
  
    conditional {
      if ($user_weekly_goal1 != null) {
        var $x1 {
          value = $user_weekly_goal1.photos_described + 1
        }
      
        db.edit user_weekly_goal {
          field_name = "user_id"
          field_value = $input.user_id
          data = {photos_described: $x1}
        } as $user_weekly_goal2
      
        function.run weekly_record {
          input = {user_id: $input.user_id, annoted_number: $x1}
        } as $func3
      }
    }
  }

  response = "OK"
}