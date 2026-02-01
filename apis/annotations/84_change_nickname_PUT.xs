query change_nickname verb=PUT {
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
  
    precondition ($user1 != null)
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {name_or_pseudonym: $input.nickname}
    } as $user2
  }

  response = {message: "OK"}
}