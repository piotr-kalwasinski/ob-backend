// Queries LOCAL cache instead of external API. Native SQL pagination — no empty pages.
query external_images_v2 verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    int page?
    int page_size?
    text category_uuid? filters=trim
  }

  stack {
    // Step 1: Get annotated external image IDs for this user
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
  
    // Step 2: Handle optional category filter
    var $category_filter_id {
      value = null
    }
  
    conditional {
      if ($input.category_uuid != null && ($input.category_uuid|strlen) > 0) {
        db.get category {
          field_name = "id"
          field_value = $input.category_uuid
        } as $category_record
      
        conditional {
          if ($category_record != null) {
            var $category_filter_id {
              value = $category_record.akty_bielik_id
            }
          }
        }
      }
    }
  
    // Step 3: Query local cache with native pagination
    conditional {
      if ($category_filter_id != null && ($annotated_ids|count) > 0) {
        db.query external_image_cache {
          where = $db.external_image_cache.category_id == $category_filter_id && (!($db.external_image_cache.external_id|in:$annotated_ids)) == true
          sort = {external_id: "asc"}
          return = {
            type  : "list"
            paging: {page: $input.page, per_page: $input.page_size}
          }
        } as $cached_images
      }
    
      elseif ($category_filter_id != null) {
        db.query external_image_cache {
          where = $db.external_image_cache.category_id == $category_filter_id
          sort = {external_id: "asc"}
          return = {
            type  : "list"
            paging: {page: $input.page, per_page: $input.page_size}
          }
        } as $cached_images
      }
    
      elseif (($annotated_ids|count) > 0) {
        db.query external_image_cache {
          where = $db.external_image_cache.external_id not in $annotated_ids
          sort = {external_id: "asc"}
          return = {
            type  : "list"
            paging: {page: $input.page, per_page: $input.page_size}
          }
        } as $cached_images
      }
    
      else {
        db.query external_image_cache {
          sort = {external_id: "asc"}
          return = {
            type  : "list"
            paging: {page: $input.page, per_page: $input.page_size}
          }
        } as $cached_images
      }
    }
  }

  response = $cached_images
}