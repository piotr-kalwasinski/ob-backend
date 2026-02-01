// Usuwa i rejestruje na nowo wszystkie ulubione kategorie usera
query "category/favorite" verb=PUT {
  api_group = "Annotations"
  auth = "user"

  input {
    uuid[]? categories_id?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null || $input.categories_id != null)
    db.bulk.delete user_favorite_categories {
      where = $db.user_favorite_categories.user_id == $auth.id
    } as $removed
  
    foreach ($input.categories_id) {
      each as $item {
        db.add user_favorite_categories {
          data = {
            created_at : "now"
            user_id    : $auth.id
            category_id: $item
          }
        } as $user_favorite_categories1
      }
    }
  }

  response = {message: "OK"}
}