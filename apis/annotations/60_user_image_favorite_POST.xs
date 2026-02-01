// Zapis zdjęcia do ulubionych
query user_image_favorite verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    // Jest to external image id nazwa uzywana `image_id` jest przez to ze tak daja na froncie
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
      where = $db.user_image_favorite.user_id == $auth.id && $db.user_image_favorite.external_image_id == $input.image_id
      return = {type: "list"}
    } as $user_image_favorite2
  
    conditional {
      if ($user_image_favorite2 == null) {
        db.add user_image_favorite {
          data = {
            created_at       : "now"
            is_favorite      : true
            external_image_id: $input.image_id
            user_id          : $auth.id
          }
        } as $user_image_favorite1
      }
    
      else {
        precondition () {
          error_type = "notfound"
        }
      }
    }
  }

  response = {message: "OK"}
}