query user_images verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    // The image file to be uploaded.
    file image_file
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
  
    // Store the uploaded image in public cloud storage.
    storage.create_image {
      value = $input.image_file
      access = "public"
      filename = `$input.image_file.name`
    } as $image_storage_details
  
    // Validate the uploaded image file
    // Validate image file type and size
    group {
      stack {
        // List of allowed image MIME types.
        var $allowed_image_types {
          value = ["image/jpeg", "image/png", "image/gif", "image/webp"]
        }
      
        // Maximum allowed image file size in bytes.
        var $max_file_size {
          value = `10485760`
        }
      
        // Ensure an image file was provided.
        precondition ($input.image_file != null) {
          error_type = "inputerror"
          error = "No image file provided."
        }
      
        // Check if the uploaded image has an allowed MIME type and that mime is not null.
        precondition ($input.image_file != null && ($image_storage_details.mime == "image/jpeg" || $image_storage_details.mime == "image/png" || $image_storage_details.mime == "image/gif" || $image_storage_details.mime == "image/webp")) {
          error_type = "inputerror"
          error = "Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed."
        }
      
        // Check if the uploaded image's size is within the allowed limit.
        precondition ($image_storage_details.size <= $max_file_size) {
          error_type = "inputerror"
          error = "File size too large. Maximum size is 10MB."
        }
      }
    }
  
    // Add image metadata to the 'image' table in the database.
    db.add image {
      data = {
        created_at         : now
        file_name          : $image_storage_details.name
        file_path          : $image_storage_details.path
        file_format        : $image_storage_details.mime
        width              : $image_storage_details.meta.width
        height             : $image_storage_details.meta.height
        file_size          : $image_storage_details.size
        source             : "user_upload"
        source_uri         : $image_storage_details.path
        source_type        : "user_generated"
        source_scope       : "INTERNAL"
        external_id        : ""
        uploaded_at        : now
        is_user_generated  : true
        is_moderated       : false
        moderation_status  : "pending"
        moderation_comments: ""
        uploaded_by_id     : $auth.id
      }
    } as $new_image_record
  
    function.run icrement_added_photo {
      input = {user_id: $auth.id}
    } as $func1
  }

  response = {
    image_id : $new_image_record.id
    image_url: $new_image_record.file_path
  }
}