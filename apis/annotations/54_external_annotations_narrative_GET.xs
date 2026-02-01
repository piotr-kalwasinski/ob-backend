query external_annotations_narrative verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    text external_annotation_id? filters=trim
  }

  stack {
    db.query image {
      where = $db.image.external_id == $input.external_annotation_id && $db.image.source_scope == "EXTERNAL"
      return = {type: "list"}
    } as $image1
  
    precondition ($image1 != null) {
      error_type = "notfound"
      error = "External image with given ID doesnt exist"
    }
  
    var $x1_image_row {
      value = $image1|first
    }
  
    db.query annotation {
      where = $db.annotation.image_id == $x1_image_row.id && $db.annotation.user_id == $auth.id
      return = {type: "list"}
    } as $annotation1
  
    var $x1_result2 {
      value = ""
    }
  
    conditional {
      if ($annotation1 == null) {
        var.update $x1_result2 {
          value = null
        }
      }
    
      else {
        var.update $x1_result2 {
          value = $annotation1.narrative_description|first
        }
      }
    }
  }

  response = {narrative_annotation: $x1_result2}
  tags = ["annotation"]
}