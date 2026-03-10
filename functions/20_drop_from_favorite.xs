// Usuwa zdj z favorite jesli user opisal to zdjecie
// 
function drop_from_favorite {
  input {
    uuid? user_id?
    int external_image_id?
  }

  stack {
    db.query user_image_favorite {
      where = $db.user_image_favorite.external_image_id == $input.external_image_id && $db.user_image_favorite.user_id == $input.user_id
      return = {type: "single"}
    } as $user_image_favorite1
  
    conditional {
      if ($user_image_favorite1 != null) {
        db.del user_image_favorite {
          field_name = "id"
          field_value = $user_image_favorite1.id
        }
      }
    }
  }

  response = "OK"
}