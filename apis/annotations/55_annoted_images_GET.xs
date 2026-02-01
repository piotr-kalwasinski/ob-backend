query annoted_images verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    db.query image {
      where = $db.image.uploaded_by_id == $auth.id
      return = {type: "list"}
      output = ["id"]
    } as $user_images
  
    var $annotated {
      value = 0
    }
  
    var $unnanotated {
      value = 0
    }
  
    foreach ($user_images) {
      each as $user_image {
        db.has annotation {
          field_name = "image_id"
          field_value = $user_image.id
        } as $annotation1
      
        conditional {
          if ($annotation1) {
            math.add $annotated {
              value = `1`
            }
          }
        
          else {
            math.add $unnanotated {
              value = `1`
            }
          }
        }
      }
    }
  }

  response = {
    annotated_images  : $annotated
    unnanotated_images: $unnanotated
  }

  tags = ["stat"]
}