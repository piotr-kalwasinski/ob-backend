function total_external_photos {
  input {
  }

  stack {
    api.request {
      url = "https://aktywakcja.bielik.ai/api/v2/stats"
      method = "GET"
      headers = []
        |push:("X-API-Key: "
          |concat:$env.aktywakcja_token_v2:""
        )
        |push:"Content-Type: application/json"
    } as $stats
  }

  response = $stats.response.result.total_images
}