// Delete user_image_favorite record.
query "user_image_favorite/{image_id}" verb=DELETE {
  api_group = "Annotations"
  auth = "user"

  input {
    int image_id?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    db.query user_image_favorite {
      where = $db.user_image_favorite.external_image_id == $input.image_id && $db.user_image_favorite.user_id == $auth.id
      return = {type: "single"}
      output = ["id"]
    } as $image_to_delete
  
    db.del user_image_favorite {
      field_name = "id"
      field_value = $image_to_delete
    }
  }

  response = "OK"
}