// Query all image records
query external_images_favourites verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    int page?
    int page_size?
  }

  stack {
    !db.query image {
      return = {type: "list"}
    } as $image
  
    var $x1_result {
      value = []
    }
  
    api.request {
      url = "https://aktywakcja.bielik.ai/api/images"
      method = "GET"
      params = {}
        |set:"page":$input.page
        |set:"page_size":$input.page_size
      headers = []
        |push:"X-API-Key: yktUs6sMcpbZ6afSuSc4ADjfw57RESCAveIScoUsHIMESPETrADyNCEntEaSEBoaHouveFy"
        |push:"Content-Type: application/json"
    } as $api1
  
    function.run getImagesFromAktywAkcja {
      input = {api1: $api1}
    } as $resp
  
    var.update $x1_result {
      value = []
    }
  
    foreach ($resp) {
      each as $item {
        var.update $item.is_favorite {
          value = true
        }
      
        array.push $x1_result {
          value = $item
        }
      }
    }
  }

  response = $x1_result
}