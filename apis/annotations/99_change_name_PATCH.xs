query change_name verb=PATCH {
  api_group = "Annotations"
  auth = "user"

  input {
    text name filters=trim
  }

  stack {
    precondition ($input.name != null) {
      error_type = "inputerror"
      error = "Fill new name"
    }
  
    db.query user {
      where = $db.user.name == $input.name
      return = {type: "count"}
    } as $user3
  
    precondition ($user3 == 0) {
      error_type = "inputerror"
      error = "Nazwa jest zajęta "
    }
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "unauthorized"
    }
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {name: $input.name}
    } as $user2
  }

  response = "OK"
}