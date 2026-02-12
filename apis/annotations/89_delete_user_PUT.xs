query delete_user verb=PUT {
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
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {status: "DELETED"}
    } as $user2
  }

  response = {message: "OK"}
}