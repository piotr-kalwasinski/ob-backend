// Zwraca 2 tablice z opisanymi i nieopisanymi zdjeciami ktore uploadowal user
query user_images verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.query image {
      join = {
        annotation: {
          table: "annotation"
          where: $db.image.id == $db.annotation.image_id
        }
      }
    
      where = $db.image.uploaded_by_id == $user1.id && $db.image.source_scope == "INTERNAL"
      eval = {
        narrative_description: $db.annotation.narrative_description
        factual_description  : $db.annotation.factual_description
        file_path_small      : $db.image.file_path|concat:"?tpl=small"
        file_path_oryginal   : $db.image.file_path|concat:"?tpl=oryginal"
        file_path            : $db.image.file_path|concat:"?tpl=big:box"
      }
    
      return = {type: "list"}
      output = [
        "id"
        "file_name"
        "file_path"
        "file_format"
        "width"
        "height"
        "file_size"
        "source"
        "source_uri"
        "source_type"
        "source_scope"
        "external_id"
        "uploaded_at"
        "is_user_generated"
        "category_id"
        "narrative_description"
        "factual_description"
        "file_path_small"
        "file_path_oryginal"
        "file_path"
      ]
    } as $x1_image_annotated_list
  
    db.query image {
      join = {
        annotation: {
          table: "annotation"
          type : "left"
          where: $db.image.id == $db.annotation.image_id
        }
      }
    
      where = $db.image.uploaded_by_id == $user1.id && $db.image.source_scope == "INTERNAL" && $db.annotation.image_id == null
      eval = {
        narrative_description: $db.annotation.narrative_description
        factual_description  : $db.annotation.factual_description
        file_path_small      : $db.image.file_path|concat:"?tpl=small"
        file_path_oryginal   : $db.image.file_path|concat:"?tpl=oryginal"
        file_path            : $db.image.file_path|concat:"?tpl=big:box"
      }
    
      return = {type: "list"}
      output = [
        "id"
        "file_name"
        "file_path"
        "file_format"
        "width"
        "height"
        "file_size"
        "source"
        "source_uri"
        "source_type"
        "source_scope"
        "external_id"
        "uploaded_at"
        "is_user_generated"
        "category_id"
        "narrative_description"
        "factual_description"
        "file_path_small"
        "file_path_oryginal"
        "file_path"
      ]
    } as $x1_image_unannotated_list
  
    // 7. Przygotuj response z obiema listami
    var $result {
      value = {
        annotated  : $x1_image_annotated_list
        unannotated: $x1_image_unannotated_list
      }
    }
  }

  response = $result
  tags = ["annotation", "images"]
}