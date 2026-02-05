function get_image_access_hash {
  input {
    // The image identifier
    uuid image_id {
      table = "image"
    }
  }

  stack {
    db.get image {
      field_name = "id"
      field_value = $input.image_id
    } as $image
  
    var $formatted_created_at {
      value = $image.created_at
        |format_timestamp:"Y-m-d\\TH:i:s.u\\Z"
        |substr:0:19
    }
  
    var $hash_input {
      value = ($env.SHORT_CODE|concat:($input.image_id|to_text))|concat:$formatted_created_at
    }
  
    var $access_hash {
      value = $hash_input|md5
    }
  }

  response = {access_hash: $access_hash}
}