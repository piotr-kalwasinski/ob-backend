// Query all user_image_favorite records
query user_image_favorite_0 verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    int page?
    int per_page?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null)
    db.query user_image_favorite {
      join = {
        external_image_cache: {
          table: "external_image_cache"
          type : "left"
          where: $db.user_image_favorite.external_image_id == $db.external_image_cache.external_id
        }
      }
    
      where = $db.user_image_favorite.user_id == $auth.id && $db.user_image_favorite.is_favorite == true
      eval = {image_url: $db.external_image_cache.image_url}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    
      output = [
        "itemsReceived"
        "curPage"
        "nextPage"
        "prevPage"
        "offset"
        "perPage"
        "items.id"
        "items.created_at"
        "items.image_id"
        "items.external_image_id"
        "items.image_url"
      ]
    } as $favorite_images
  
    db.query user_image_favorite {
      where = $db.user_image_favorite.user_id == $auth.id && $db.user_image_favorite.is_favorite == true
      return = {type: "count"}
    } as $total_count
  
    var.update $favorite_images.total_count {
      value = `$total_count`
    }
  }

  response = $favorite_images
}