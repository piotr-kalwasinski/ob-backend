// Edit user_image_favorite record
query "user_image_favorite/{user_image_favorite_id}" verb=PATCH {
  api_group = "Annotations"
  auth = "user"

  input {
    int user_image_favorite_id?
  }

  stack {
    db.patch user_image_favorite {
      field_name = "id"
      field_value = $input.user_image_favorite_id
      data = {}
    } as $user_image_favorite1
  }

  response = $user_image_favorite
}