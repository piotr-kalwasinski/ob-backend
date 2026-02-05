// List of external kategories form V2 db
query external_categories verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    api.request {
      url = "https://aktywakcja.bielik.ai/api/v2/categories"
      method = "GET"
      headers = []
        |push:("X-API-Key: "
          |concat:$env.aktywakcja_token_v2:""
        )
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $api1.response.result
}