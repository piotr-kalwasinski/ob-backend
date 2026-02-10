// Query all image records
query external_images_v2 verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    int page?
    int page_size?
    text? category_uuid? filters=trim
  }

  stack {
    var $x1_result {
      value = []
    }
  
    db.query annotation {
      join = {
        image: {
          table: "image"
          where: $db.annotation.image_id == $db.image.id
        }
      }
    
      where = $db.annotation.user_id == $auth.id && $db.annotation.is_external_image == true
      eval = {external_image_id: $db.image.external_id}
      return = {type: "list"}
    } as $annotation1
  
    conditional {
      if ($input.category_uuid == null) {
        api.request {
          url = "https://aktywakcja.bielik.ai/api/v2/images"
          method = "GET"
          params = {}
            |set:"page":$input.page
            |set:"per_page":$input.page_size
          headers = []
            |push:("X-API-Key: "
              |concat:$env.aktywakcja_token_v2:""
            )
            |push:"Content-Type: application/json"
        } as $api1
      
        function.run getImagesFromAktywAkcja {
          input = {api1: $api1, annotation_list: $annotation1}
        } as $resp
      
        var.update $x1_result {
          value = $resp
        }
      }
    
      else {
        db.get category {
          field_name = "id"
          field_value = $input.category_uuid
        } as $category1
      
        api.request {
          url = "https://aktywakcja.bielik.ai/api/v2/images"
          method = "GET"
          params = {}
            |set:"category_id":$category1.akty_bielik_id
            |set:"page":$input.page
            |set:"per_page":$input.page_size
          headers = []
            |push:("X-API-Key: "
              |concat:$env.aktywakcja_token_v2:""
            )
            |push:"Content-Type: application/json"
        } as $api1
      
        function.run getImagesFromAktywAkcja {
          input = {api1: $api1, annotation_list: $annotation1}
        } as $resp
      
        var.update $x1_result {
          value = $resp
        }
      }
    }
  }

  response = $x1_result
}