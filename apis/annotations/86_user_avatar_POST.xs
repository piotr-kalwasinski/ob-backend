query user_avatar verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    file? avatar_file
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    storage.create_image {
      value = $input.avatar_file
      access = "public"
      filename = `$input.avatar_file.name`
    } as $avatar_details
  
    group {
      stack {
        var $allowed_mime {
          value = ["image/jpeg", "image/png", "image/gif", "image/webp"]
        }
      
        var $max_file_size {
          value = 10485760
        }
      
        precondition ($input.avatar_file != null) {
          error_type = "inputerror"
          error = "No image file provided."
        }
      
        precondition ($avatar_details.path != null) {
          error_type = "inputerror"
        }
      
        precondition ($avatar_details.size <= $max_file_size) {
          error_type = "inputerror"
          error = "File size too large. Maximum size is 10MB."
        }
      }
    }
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {avatar_path: $avatar_details.path}
    } as $user2
  }

  response = {avatar_url: $avatar_details.path}
}