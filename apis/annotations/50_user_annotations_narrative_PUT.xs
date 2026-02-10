// Aktualizacja opisu zdjęcia USERA (narracyjny)
query user_annotations_narrative verb=PUT {
  api_group = "Annotations"
  auth = "user"

  input {
    uuid? id?
    text narrative_description? filters=trim
  }

  stack {
    db.query annotation {
      where = $db.annotation.id == $db.annotation.id && $db.annotation.user_id == $auth.id
      return = {type: "list"}
    } as $annotation2
  
    precondition ($annotation2 != null) {
      error_type = "badrequest"
    }
  
    var $x1_annotation {
      value = $annotation2|first
    }
  
    db.edit annotation {
      field_name = "id"
      field_value = $x1_annotation.id
      data = {
        created_at           : now
        narrative_description: $input.narrative_description
        updated_at           : now
        is_external_image    : false
      }
    } as $annotation1
  }

  response = "OK"
}