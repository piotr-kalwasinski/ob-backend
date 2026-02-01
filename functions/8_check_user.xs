function check_user {
  input {
    uuid? token?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $input.token
    } as $user1
  }

  response = $user1
}