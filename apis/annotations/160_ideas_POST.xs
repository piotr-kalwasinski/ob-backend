query ideas verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    // Pomysl usera
    text idea filters=trim
  }

  stack {
    var $lenght {
      value = `$input.idea|strlen`
    }
  
    precondition ($lenght <= 1000) {
      error_type = "inputerror"
      payload = "Za dlugi opis"
    }
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    db.add ideas {
      data = {
        created_at: "now"
        user_id   : $user1.id
        idea      : $input.idea
      }
    } as $ideas1
  }

  response = "OK"
}