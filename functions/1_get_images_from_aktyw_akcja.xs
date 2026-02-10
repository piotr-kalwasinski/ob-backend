function getImagesFromAktywAkcja {
  input {
    json api1?
    object annotation_list? {
      schema
    }
  }

  stack {
    var $x1_result {
      value = []
    }
  
    var $x1_row {
      value = $input.api1.response.result.images
    }
  
    foreach ($x1_row) {
      each as $item {
        var $x1_image_url {
          value = $item.image_url|json_encode
        }
      
        conditional {
          if ((!($input.annotation_list|get:"external_image_id"|has:$item.id)) != true) {
            array.push $x1_result {
              value = $item
            }
          }
        }
      }
    }
  
    util.get_vars as $__all_vars
  }

  response = $x1_result
}