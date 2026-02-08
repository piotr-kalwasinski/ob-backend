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
  
    db.bulk.delete annotation {
      where = $db.annotation.image_id == $input.image_id && $db.annotation.user_id == $auth.id
    } as $annotation1
  
    db.bulk.delete image {
      where = $db.image.id == $input.image_id && $db.image.uploaded_by_id == $auth.id
    } as $image1
  
    function.run reduction_added_photo {
      input = {user_id: $auth.id}
    } as $func1
  }

  response = "OK"
}