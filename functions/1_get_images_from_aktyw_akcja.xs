function getImagesFromAktywAkcja {
  input {
    json api1?
    int[] annotation_ids?
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
        !array.push $x1_result {
          value = $item
        }
      
        !var $x1_image_url {
          value = $item.image_url|json_encode
        }
      
        // Condition to check if item.id does NOT exist in the external list
        conditional {
          if (( $input.annotation_ids|find:$$==$var.item.id) != $item.id) {
            array.push $x1_result {
              value = $item
            }
          }
        }
      }
    }
  }

  response = $x1_result
}