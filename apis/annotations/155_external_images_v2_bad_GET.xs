// Queries LOCAL cache instead of external API. Native SQL pagination — no empty pages.
// Uses LEFT JOIN to exclude images already annotated by the current user.
query external_images_v2_BAD verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    int page?
    int page_size?
    text category_uuid? filters=trim
  }

  stack {
    // Step 1: Resolve optional category filter to akty_bielik_id
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
  
    // Step 2: Query cache with LEFT JOINs to exclude user-annotated images
    // LEFT JOIN image ON external_id, then LEFT JOIN annotation ON image_id + user
    // WHERE annotation.id IS NULL => image not yet annotated by this user
    // category_id ==? ignores the filter when $category_filter_id is null
    db.query external_image_cache {
      join = {
        image     : {
          table: "image"
          type : "left"
          where: $db.external_image_cache.external_id == $db.image.external_id
        }
        annotation: {
          table: "annotation"
          type : "left"
          where: $db.image.id == $db.annotation.image_id && $db.annotation.user_id == $auth.id && $db.annotation.is_external_image == true
        }
      }
    
      where = $db.annotation.id == null && $db.external_image_cache.category_id ==? $category_filter_id
      sort = {external_id: "asc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.page_size}
      }
    } as $cached_images
  }

  response = $cached_images
}