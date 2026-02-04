query user_image_favorite_count verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null)
    db.query user_image_favorite {
      where = $db.user_image_favorite.user_id == $auth.id && $db.user_image_favorite.is_favorite == true
      return = {type: "count"}
    } as $image_favorite_count
  }

  response = $image_favorite_count
}