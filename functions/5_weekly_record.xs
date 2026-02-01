function weekly_record {
  input {
    uuid? user_id?
    int annoted_number?
  }

  stack {
    db.get user_stat {
      field_name = "user_id"
      field_value = $input.user_id
    } as $user_stat2
  
    conditional {
      if ($user_stat2 != null && $user_stat2.weekly_goal_record < $input.annoted_number) {
        db.edit user_stat {
          field_name = "user_id"
          field_value = $input.user_id
          data = {weekly_goal_record: $input.annoted_number}
        } as $user_stat1
      }
    }
  }

  response = "OK"
}