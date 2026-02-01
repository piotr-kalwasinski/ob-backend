// Login and retrieve an authentication token
query "auth/login" verb=POST {
  api_group = "Authentication"

  input {
    email email? filters=trim|lower
    text password?
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email
      output = ["id", "created_at", "name", "email", "password"]
    } as $user
  
    precondition ($user != null) {
      error_type = "accessdenied"
      error = "Invalid Credentials."
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $user.password
    } as $pass_result
  
    precondition ($pass_result) {
      error_type = "accessdenied"
      error = "Invalid Credentials."
    }
  
    db.edit user {
      field_name = "id"
      field_value = $user.id
      data = {last_login: now}
    } as $user1
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 604800
      id = $user.id
    } as $authToken
  }

  response = {authToken: $authToken}
}