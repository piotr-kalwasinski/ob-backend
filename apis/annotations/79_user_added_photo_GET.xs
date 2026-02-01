query user_added_photo verb=GET {
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
      error_type = "badrequest"
    }
  
    db.query image {
      where = $db.image.uploaded_by_id == $auth.id
      return = {type: "count"}
    } as $img_count
  }

  response = $img_count
}