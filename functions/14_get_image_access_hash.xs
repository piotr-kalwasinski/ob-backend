function get_image_access_hash {
  input {
    // The image identifier
    uuid image_id {
      table = "image"
    }
  
    text created_at_str? filters=trim
    int image_id_int?
  }

  stack {
    !var $formatted_created_at {
      value = $image.created_at
        |format_timestamp:"Y-m-d\\TH:i:s.u\\Z"
        |substr:0:19
    }
  
    var $hash_input {
      value = ($env.SHORT_CODE|concat:'|'|concat:($input.image_id_int|to_text))|concat:'|'|concat:$input.created_at_str
    }
  
    var $access_hash {
      value = $hash_input|md5
    }
  }

  response = {access_hash: $access_hash}
}