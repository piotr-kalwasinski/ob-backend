// consents
query consents verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    bool privacy_consent
    bool service_consent
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {
        privacy_policy_accepted_date: now
        privacy_consent             : $input.privacy_consent
        service_consent             : $input.service_consent
      }
    } as $user2
  
    precondition ($user2 != null) {
      error_type = "badrequest"
      error = "Incorrect user ID"
    }
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {
        privacy_consent: $input.privacy_consent
        service_consent: $input.service_consent
      }
    } as $user1
  }

  response = "OK"
}