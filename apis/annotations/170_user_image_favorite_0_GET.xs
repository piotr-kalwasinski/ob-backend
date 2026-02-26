// Query all user_image_favorite records
query user_image_favorite_0 verb=GET {
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
    var $favorite_images_arr {
      value = []
    }
  
    db.query user_image_favorite {
      where = $db.user_image_favorite.user_id == $auth.id && $db.user_image_favorite.is_favorite == true
      return = {type: "list"}
    } as $favorite_images
  
    foreach ($favorite_images) {
      each as $favorite_image {
        array.push $favorite_images_arr {
          value = `"https://aktywakcja.bielik.ai/api/images/" | concat:"/show":$favorite_image.external_image_id`
        }
      }
    }
  }

  response = {favorite_images: $favorite_images_arr}
}