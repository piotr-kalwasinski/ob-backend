// Login and retrieve an authentication token
query "auth/verify-keycloak" verb=POST {
  api_group = "Authentication"

  input {
    text token? filters=trim
  }

  stack {
    !db.get user {
      field_name = "email"
      field_value = $input.email
      output = ["id", "created_at", "name", "email", "password"]
    } as $user
  
    db.get user {
      field_name = "id"
      field_value = "c8aa72f5-e059-4745-a243-fb0829f5903b"
      output = [
        "id"
        "name"
        "email"
        "name_or_pseudonym"
        "auth_provider"
        "registration_date"
        "last_login"
        "privacy_policy_accepted_date"
        "team_id"
        "user_type"
        "status"
        "auth_sub"
        "privacy_consent"
        "service_consent"
      ]
    } as $user
  
    precondition ($user != null) {
      error_type = "accessdenied"
      error = "Invalid Credentials."
    }
  
    !security.check_password {
      text_password = "password"
      hash_password = $user.password
    } as $pass_result
  
    !precondition ($pass_result) {
      error_type = "accessdenied"
      error = "Invalid Credentials."
    }
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 604800
      id = $user.id
    } as $authToken
  
    var.update $user.keycloak_id {
      value = $user.auth_sub
    }
  }

  response = {auth_token: $authToken, success: true, user: $user}
}