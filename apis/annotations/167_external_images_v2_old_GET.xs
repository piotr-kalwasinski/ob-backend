// Zwraca listę niezanotowanych zdjęć z Aktyw Akcja z paginacją kursorową
query external_images_v2_old verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    // Numer strony zewnętrznego API, od której zacząć (domyślnie 1)
    int cursor?
  
    // Ile niezanotowanych obrazów zwrócić
    int page_size?
  
    // UUID kategorii do filtrowania
    text category_uuid? filters=trim
  }

  stack {
    // 1. Pobierz listę external_id obrazów już zanotowanych przez tego użytkownika
    db.query annotation {
      join = {
        image: {
          table: "image"
          where: $db.annotation.image_id == $db.image.id
        }
      }
    
      where = $db.annotation.user_id == $auth.id && $db.annotation.is_external_image == true
      eval = {external_image_id: $db.image.external_id}
      return = {type: "list"}
      output = ["external_image_id"]
    } as $annotation1
  
    var $annotated_ids {
      value = `$var.annotation1|map:$$.external_image_id`
    }
  
    // 2. Wywołaj funkcję z pętlą paginacyjną
    function.run getImagesFromAktywAkcja {
      input = {
        cursor        : $input.cursor
        page_size     : $input.page_size
        category_uuid : $input.category_uuid
        annotation_ids: $annotated_ids
      }
    } as $result
  }

  response = $result
}