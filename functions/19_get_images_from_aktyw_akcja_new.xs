function getImagesFromAktywAkcja_new {
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
        // Only add image if its id is NOT in the annotated list
        conditional {
          if (($input.annotation_ids|find:$$ == $var.item.id) != $item.id) {
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