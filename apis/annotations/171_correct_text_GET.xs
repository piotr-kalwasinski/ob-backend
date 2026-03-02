// Endpoint do poprawy tekstu przez LLMa
query correct_text verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    text description filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    api.request {
      url = "https://aktywakcja.bielik.ai/api/v2/correct"
      method = "POST"
      params = {}
        |set:"description":$input.description
      headers = []
        |push:("X-API-Key: "
          |concat:$env.aktywakcja_token_v2:""
        )
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $api1.response.result.corrected_description
}