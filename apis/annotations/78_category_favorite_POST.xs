// Rejestracja ulubionych kategori usera
query "category/favorite" verb=POST {
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