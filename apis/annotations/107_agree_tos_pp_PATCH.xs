// Endpoint for agreeing to Terms of Service and Privacy Policy
query agree_tos_pp verb=PATCH {
  api_group = "Annotations"
  auth = "user"

  input {
    // Agree of Terms of Service
    bool tos
  
    // Agree private policy
    bool pp
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
      data = {
        privacy_policy_accepted_date: now
        privacy_consent             : $input.pp
        service_consent             : $input.tos
      }
    } as $user2
  }

  response = {message: "OK"}
}