query update_team verb=PUT {
  api_group = "Annotations"
  auth = "user"

  input {
    uuid? team_id
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != $auth.id) {
      error_type = "accessdenied"
    }
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {team_id: $input.team_id}
    } as $user2
  }

  response = {message: "OK"}
}