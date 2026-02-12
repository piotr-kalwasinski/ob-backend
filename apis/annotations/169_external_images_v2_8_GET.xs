// Stara wersja bez usuwania
query external_images_v2_8 verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    // Numer strony zewnętrznego API, od której zacząć (domyślnie 1)
    int cursor?
  
    // Ile niezanotowanych obrazów zwrócić
    int page_size?
  
    // UUID kategorii do filtrowania
    text category_uuid? filters=trim
  
    int page?
  }

  stack {
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
      output = ["external_image_id"]
    } as $annotation1
  
    var $annotated_ids {
      value = `$var.annotation1|map:$$.external_image_id`
    }
  
    var $x1_result {
      value = ""
    }
  
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
          input = {api1: $api1, annotation_ids: $annotated_ids}
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
          input = {api1: $api1, annotation_ids: $annotated_ids}
        } as $resp
      
        var.update $x1_result {
          value = $resp
        }
      }
    }
  
    !function.run getImagesFromAktywAkcja {
      input = {
        cursor        : $input.cursor
        page_size     : $input.page_size
        category_uuid : $input.category_uuid
        annotation_ids: $annotated_ids
      }
    } as $result
  }

  response = $x1_result
}