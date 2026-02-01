query user_avatar verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "unauthorized"
      error = "user"
    }
  
    conditional {
      if ($user1.avatar_path == null) {
        var $avatar {
          value = ""
        }
      }
    
      else {
        var $avatar {
          value = `"https://xe7h-ziuu-timf.n7e.xano.io/"|concat:$user1.avatar_path`
        }
      }
    }
  }

  response = {avatar_url: $avatar}
}