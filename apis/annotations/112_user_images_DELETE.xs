query user_images verb=DELETE {
  api_group = "Annotations"
  auth = "user"

  input {
    uuid? image_id?
  }

  stack {
    // Fetch the authenticated user's record to ensure they exist.
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $authenticated_user
  
    precondition ($authenticated_user != null) {
      error_type = "accessdenied"
      error = "Authenticated user not found."
    }
  
    db.del image {
      field_name = "id"
      field_value = $input.image_id
    }
  
    function.run reduction_added_photo {
      input = {user_id: $auth.id}
    } as $func1
  }

  response = "OK"
}