// Stara wersja bez usuwania
query external_images_v2_8 verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
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
        db.query external_image_cache {
          where = $db.external_image_cache.external_id not in $annotated_ids
          return = {
            type  : "list"
            paging: {page: $input.page, per_page: $input.page_size}
          }
        
          output = [
            "itemsReceived"
            "curPage"
            "nextPage"
            "prevPage"
            "offset"
            "perPage"
            "items.id"
            "items.external_id"
            "items.image_url"
            "items.thumbnail_url"
            "items.category_id"
            "items.category_name"
            "items.external_created_at"
            "items.synced_at"
          ]
        } as $external_image_cache1
      
        !db.query external_image_cache {
          join = {
            annotation: {
              table: "annotation"
              type : "left"
              where: $db.annotation.external_image_id == $db.external_image_cache.external_id
            }
          }
        
          where = $db.annotation.is_external_image == true && $db.annotation.user_id == $auth.id
          eval = {
            narrative_description: $db.annotation.narrative_description
          }
        
          return = {type: "list"}
        } as $external_image_cache1
      
        var.update $x1_result {
          value = $external_image_cache1.items
        }
      }
    
      else {
        db.get category {
          field_name = "id"
          field_value = $input.category_uuid
        } as $category1
      
        db.query external_image_cache {
          where = $db.external_image_cache.external_id not in $annotated_ids && $db.external_image_cache.category_id == $category1.akty_bielik_id
          return = {
            type  : "list"
            paging: {page: $input.page, per_page: $input.page_size}
          }
        
          output = [
            "itemsReceived"
            "curPage"
            "nextPage"
            "prevPage"
            "offset"
            "perPage"
            "items.id"
            "items.external_id"
            "items.image_url"
            "items.thumbnail_url"
            "items.category_id"
            "items.category_name"
            "items.external_created_at"
            "items.synced_at"
          ]
        } as $external_image_cache1
      
        var.update $x1_result {
          value = $external_image_cache1.items
        }
      }
    }
  }

  response = $x1_result
}