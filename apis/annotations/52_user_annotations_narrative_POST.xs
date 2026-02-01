// Zapis opisu zdjęcia USERA  (narracyjny)
query user_annotations_narrative verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    uuid? image_uuid?
    text narrative_description filters=trim
  }

  stack {
    db.query annotation {
      where = $db.annotation.image_id == $input.image_uuid && $db.annotation.user_id == $auth.id
      return = {type: "list"}
    } as $annotation2
  
    precondition ($annotation2 == null) {
      error_type = "badrequest"
      error = "Incorrect duplicated annotation"
    }
  
    db.get image {
      field_name = "id"
      field_value = $input.image_uuid
    } as $image1
  
    db.add annotation {
      data = {
        id                   : null|uuid
        created_at           : "now"
        narrative_description: $input.narrative_description
        updated_at           : now
        is_corrected         : false
        verification_status  : "PENDING"
        image_id             : $image1.id
        user_id              : $auth.id
      }
    } as $annotation1
  
    function.run updateUserAnnotationStat {
      input = {user_id: $auth.id}
    } as $func1
  
    function.run icrement_annotated_photos {
      input = {user_id: $auth.id}
    } as $func2
  }

  response = "OK"
}