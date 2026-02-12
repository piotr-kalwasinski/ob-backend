query change_name verb=PUT {
  api_group = "Annotations"
  auth = "user"

  input {
    text nickname? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.query user {
      where = $db.user.name == $input.nickname
      return = {type: "count"}
    } as $user3
  
    precondition ($user3 == 0) {
      error_type = "inputerror"
      payload = "Taka nazwa istnieje "
    }
  
    precondition ($user1 != null)
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {name: $input.nickname}
    } as $user2
  }

  response = {message: "OK"}
}