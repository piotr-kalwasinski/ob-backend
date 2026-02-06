query user_avatar verb=DELETE {
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
      error_type = "unauthorized"
      error = "user"
    }
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {avatar_path: ""}
    } as $user2
  }

  response = "OK"
}