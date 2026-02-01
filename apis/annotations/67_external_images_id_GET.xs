// Query all image records
query "external_images/{id}" verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    text id? filters=trim
  }

  stack {
    !db.query image {
      return = {type: "list"}
    } as $image
  
    api.request {
      url = 'https://aktywakcja.bielik.ai/api/images/' ~ $input.id
      method = "GET"
      headers = []
        |push:"X-API-Key: yktUs6sMcpbZ6afSuSc4ADjfw57RESCAveIScoUsHIMESPETrADyNCEntEaSEBoaHouveFy"
        |push:"Content-Type: application/json"
    } as $api1
  
    precondition ($api1 != null && $api1.response.result != null) {
      error_type = "notfound"
      error = "Not found"
    }
  
    var $prev_photo {
      value = $input.id + 1
    }
  
    var $next_photo {
      value = $input.id - 1
    }
  
    var $x1_result {
      value = $api1.response.result
    }
  
    var $payload {
      value = {
        prev  : $prev_photo
        next  : $next_photo
        result: $x1_result
      }
    }
  }

  response = $payload
}