// Endpoint for getting  agreeing to Terms of Service and Privacy Policy
query agree_tos_pp verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != $auth.id) {
      error_type = "accessdenied"
    }
  }

  response = {pp: $user1.privacy_consent, tos: $user1.service_consent}
}