// Zwraca 2 tablice z opisanymi i nieopisanymi zdjeciami ktore uploadowal user + ZDJECIA ZEWNETRZNE
query get_user_images_with_annotation verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    // 1. Walidacja użytkownika
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1.id != null) {
      error_type = "unauthorized"
    }
  
    // 2. Zdjęcia Z adnotacjami (INNER JOIN + Add-on)
    db.query image {
      join = {
        annotation: {
          table: "annotation"
          where: $db.image.id == $db.annotation.image_id && $db.annotation.user_id == $auth.id
        }
      }
    
      return = {type: "list"}
      addon = [
        {
          name : "annotation_of_image"
          input: {image_id: $output.id}
          as   : "_annotation_of_image"
        }
      ]
    } as $annotated
  
    // 3. Zdjęcia BEZ adnotacji - query tylko image bez JOIN
    db.query image {
      where = $db.image.uploaded_by_id == $auth.id
      return = {type: "list"}
    } as $all_images
  
    // 4. Pobierz wszystkie image_id które mają adnotacje
    db.query annotation {
      where = $db.annotation.user_id == $auth.id
      return = {type: "list"}
    } as $annotations_list
  
    // 5. Stwórz tablicę ID zdjęć z adnotacjami
    var $annotated_image_ids {
      value = []
    }
  
    foreach ($annotations_list) {
      each as $ann {
        array.push $annotated_image_ids {
          value = `$ann.image_id`
        }
      }
    }
  
    // 6. Filtruj zdjęcia które NIE mają adnotacji
    var $unannotated {
      value = []
    }
  
    foreach ($all_images) {
      each as $img {
        conditional {
          if (`$annotated_image_ids|in:$img.id` == false) {
            array.push $unannotated {
              value = `$img`
            }
          }
        }
      }
    }
  
    // 7. Przygotuj response z obiema listami
    var $result {
      value = {annotated: $annotated, unannotated: $unannotated}
    }
  }

  response = $result
  tags = ["annotation", "images"]
}