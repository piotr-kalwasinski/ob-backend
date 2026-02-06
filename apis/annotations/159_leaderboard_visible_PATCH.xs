// Zmiana widocznosci usera na tabeli wynikow
query "leaderboard/visible" verb=PATCH {
  api_group = "Annotations"
  auth = "user"

  input {
    bool visible?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {leaderbord_visible: $input.visible}
    } as $user2
  }

  response = "OK"
}