query "external_image_v2_ak/display" verb=GET {
  api_group = "Annotations"

  input {
    // The unique identifier for the image to be displayed.
    text id? filters=trim
  
    // Optional size for the image, allowing it to be scaled.
    int size?
  }

  stack {
    // Construct the base URL for fetching the image from the external service.
    var $x1_url {
      value = 'https://aktywakcja.bielik.ai/api/images/'~$input.id~'/show'
    }
  
    // Conditionally add the image size parameter to the URL if provided.
    conditional {
      if ($input.size != null) {
        // Append the requested size parameter to the image URL.
        var.update $x1_url {
          value = $x1_url ~ '?size=' ~ $input.size
        }
      }
    }
  
    // Fetch the image data from the external image service using the prepared URL.
    api.request {
      url = $x1_url
      method = "GET"
      timeout = 30
      verify_host = false
      verify_peer = false
    } as $image_response
  
    // Initialize a variable to store the image's content type, defaulting to JPEG.
    var $x1_content {
      value = `"image/jpeg"`
    }
  
    // Initialize a variable to store the image's content length, defaulting to zero.
    var $x1_length {
      value = `0`
    }
  
    // Iterate through the response headers to extract content type and length.
    foreach ($image_response.response.headers) {
      each as $header_line {
        // Check each header line to identify content type and content length.
        conditional {
          if ($header_line|istarts_with:"content-type:") {
            // Extract and store the Content-Type from the response headers.
            var.update $x1_content {
              value = $header_line|replace:"content-type: ":""
            }
          }
        
          elseif ($header_line|istarts_with:"content-length:") {
            // Extract and store the Content-Length from the response headers.
            var.update $x1_length {
              value = $header_line
                |replace:"content-length: ":""
                |to_int
            }
          }
        }
      }
    }
  
    // Set the Content-Type header for the API's response to match the external image.
    util.set_header {
      value = "Content-Type: " ~ $x1_content
      duplicates = "replace"
    }
  
    // Set the Content-Length header for the API's response to match the external image.
    util.set_header {
      value = "Content-Length: " ~ $x1_length
      duplicates = "replace"
    }
  }

  response = $image_response.response.result
  cache = {
    ttl       : 3600
    input     : true
    auth      : true
    datasource: true
    ip        : false
    headers   : []
    env       : []
  }
}