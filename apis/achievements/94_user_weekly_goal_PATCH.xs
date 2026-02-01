query user_weekly_goal verb=PATCH {
  api_group = "Achievements"
  auth = "user"

  input {
    uuid? weekly_goal
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    db.edit user_weekly_goal {
      field_name = "user_id"
      field_value = $auth.id
      data = {weekly_goal_id: $input.weekly_goal}
    } as $user_weekly_goal1
  }

  response = {message: "OK"}
}