// Zwraca ulubione kategorie usera
query "category/favorite" verb=GET {
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
    db.query user_favorite_categories {
      where = $db.user_favorite_categories.user_id == $auth.id
      return = {type: "list"}
    } as $user_favorite_categories1
  }

  response = $user_favorite_categories1
}