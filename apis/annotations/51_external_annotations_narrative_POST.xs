// User narrative recording but it relates to images from external sources
query external_annotations_narrative verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    text external_image_id? filters=trim
    text narrative_description? filters=trim
  }

  stack {
    db.query image {
      where = $db.image.external_id == $input.external_image_id && $db.image.source_type == "EXTERNAL"
      return = {type: "list"}
    } as $x1_image_external
  
    var $x1_image_uuid {
      value = ""
    }
  
    conditional {
      if ($x1_image_external == null) {
        api.request {
          url = 'https://aktywakcja.bielik.ai/api/images/' ~$input.external_image_id
          method = "GET"
          headers = []
            |push:"X-API-Key: yktUs6sMcpbZ6afSuSc4ADjfw57RESCAveIScoUsHIMESPETrADyNCEntEaSEBoaHouveFy"
        } as $api1
      
        db.add image {
          data = {
            id                 : null|uuid
            created_at         : "now"
            file_name          : $api1.response.result.file_name
            file_path          : $api1.response.result.file_path
            file_format        : ""
            width              : 0
            height             : 0
            file_size          : 0
            source             : "aktywakcja"
            source_uri         : $api1.response.result.image_url
            source_type        : "aktywakcja"
            source_scope       : "EXTERNAL"
            external_id        : $api1.response.result.id
            uploaded_at        : now
            is_user_generated  : false
            is_moderated       : false
            moderation_status  : "ACCEPTED"
            moderation_comments: ""
            uploaded_by_id     : $auth.id
          }
        } as $image1
      
        var.update $x1_image_uuid {
          value = $image1.id
        }
      }
    
      else {
        var.update $x1_image_uuid {
          value = $x1_image_external|first
        }
      }
    }
  
    db.add annotation {
      data = {
        created_at                : "now"
        narrative_description     : $input.narrative_description
        factual_description       : ""
        auto_generated_description: ""
        updated_at                : now
        is_corrected              : false
        verification_status       : "PENDING"
        image_id                  : $x1_image_uuid
        user_id                   : $auth.id
        verified_by_user_id       : null
        is_external_image         : true
      }
    } as $annotation1
  
    function.run icrement_annotated_photos {
      input = {user_id: $auth.id}
    } as $func1
  
    function.run updateUserAnnotationStat {
      input = {user_id: $auth.id}
    } as $func2
  }

  response = "OK"
  tags = ["annotation"]
}