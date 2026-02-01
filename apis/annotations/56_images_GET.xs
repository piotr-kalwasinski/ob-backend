// Query all image records
query images verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    int page?
    int page_size?
  
    // The list of categories for search
    uuid[:10]? category_uuids?
  }

  stack {
    db.query image {
      return = {type: "list"}
    } as $image
  
    var $x1_result {
      value = []
    }
  
    conditional {
      if ($input.category_uuids == null || $input.category_uuids == []) {
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
          value = $resp
        }
      }
    
      else {
        foreach ($input.category_uuids) {
          each as $item {
            db.get category {
              field_name = "id"
              field_value = $item
            } as $category1
          
            api.request {
              url = "https://aktywakcja.bielik.ai/api/images"
              method = "GET"
              params = {}
                |set:"page":$input.page
                |set:"page_size":$input.page_size
                |set:"category_id":$category1.akty_bielik_id
              headers = []
                |push:"X-API-Key: yktUs6sMcpbZ6afSuSc4ADjfw57RESCAveIScoUsHIMESPETrADyNCEntEaSEBoaHouveFy"
                |push:"Content-Type: application/json"
            } as $api1
          
            function.run getImagesFromAktywAkcja {
              input = {api1: $api1}
            } as $resp
          
            foreach ($resp) {
              each as $item_to_result {
                array.push $x1_result {
                  value = $item_to_result
                }
              }
            }
          }
        }
      }
    }
  }

  response = $x1_result
  cache = {
    ttl       : 3600
    input     : true
    auth      : true
    datasource: true
    ip        : false
    headers   : []
    env       : []
  }
}