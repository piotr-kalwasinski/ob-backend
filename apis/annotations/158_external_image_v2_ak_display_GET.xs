query "external_image_v2_ak/display" verb=GET {
  api_group = "Annotations"

  input {
    // The unique identifier for the image to be displayed.
    text? id? filters=trim
  
    // Optional size for the image, allowing it to be scaled.
    int size?
  
    text external_url? filters=trim
  }

  stack {
    var $x1_url {
      value = $input.external_url
    }
  
    conditional {
      if ($input.size != null) {
        var.update $x1_url {
          value = $x1_url ~ '?size=' ~ $input.size
        }
      }
    }
  
    api.request {
      url = $x1_url
      method = "GET"
      timeout = 30
      verify_host = false
      verify_peer = false
    } as $image_response
  
    var $x1_content {
      value = `"image/jpeg"`
    }
  
    var $x1_length {
      value = `0`
    }
  
    foreach ($image_response.response.headers) {
      each as $header_line {
        conditional {
          if ($header_line|istarts_with:"content-type:") {
            var.update $x1_content {
              value = $header_line|replace:"content-type: ":""
            }
          }
        
          elseif ($header_line|istarts_with:"content-length:") {
            var.update $x1_length {
              value = $header_line
                |replace:"content-length: ":""
                |to_int
            }
          }
        }
      }
    }
  
    util.set_header {
      value = "Content-Type: " ~ $x1_content
      duplicates = "replace"
    }
  
    util.set_header {
      value = "Content-Length: " ~ $x1_length
      duplicates = "replace"
    }
  }

  response = $image_response.response.result
  cache = {
    ttl       : 240
    input     : true
    auth      : true
    datasource: false
    ip        : true
    headers   : []
    env       : []
  }
}