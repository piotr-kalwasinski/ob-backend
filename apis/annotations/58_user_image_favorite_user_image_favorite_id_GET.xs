// Get user_image_favorite record
query "user_image_favorite/{user_image_favorite_id}" verb=GET {
  api_group = "Annotations"

  input {
    uuid user_image_favorite_id?
  }

  stack {
    db.get "" {
      field_name = "id"
      field_value = $input.user_image_favorite_id
    } as $user_image_favorite
  
    precondition ($user_image_favorite != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $user_image_favorite
}