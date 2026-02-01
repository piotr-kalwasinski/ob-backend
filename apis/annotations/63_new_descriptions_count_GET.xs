query new_descriptions_count verb=GET {
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
      error_type = "badrequest"
    }
  
    db.query annotation {
      where = $db.annotation.created_at >= $user1.last_login
      return = {type: "count"}
    } as $no_of_desc
  }

  response = $no_of_desc
  tags = ["stat"]
}