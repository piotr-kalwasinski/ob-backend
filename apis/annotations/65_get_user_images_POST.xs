query get_user_images verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    int page? filters=min:1
    int per_page? filters=min:1
    uuid[]? category_ids?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "badrequest"
    }
  
    db.query image {
      where = $db.image.uploaded_by_id == $user1.id
      return = {
        type  : "list"
        paging: {
          page    : $input.page
          per_page: $input.per_page
          totals  : true
        }
      }
    
      output = [
        "itemsReceived"
        "curPage"
        "nextPage"
        "prevPage"
        "offset"
        "perPage"
        "itemsTotal"
        "pageTotal"
        "items.id"
        "items.file_name"
        "items.file_path"
        "items.file_format"
        "items.width"
        "items.height"
        "items.file_size"
        "items.source"
        "items.source_uri"
        "items.source_type"
        "items.source_scope"
        "items.uploaded_at"
      ]
    } as $image1
  
    foreach ($image1.items) {
      each as $item {
        var.update $item.source_uri {
          value = $env.image_base_public_url ~'/'~ $var.item.source_uri
        }
      }
    }
  }

  response = $image1
}