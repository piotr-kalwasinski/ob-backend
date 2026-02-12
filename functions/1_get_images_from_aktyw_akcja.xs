function getImagesFromAktywAkcja {
  input {
    json api1?
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
      
        array.push $x1_result {
          value = $item
        }
      }
    }
  
    util.get_vars as $__all_vars
  }

  response = $x1_result
}