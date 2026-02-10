table annotation {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    text narrative_description?
    text factual_description?
    text auto_generated_description?
    timestamp updated_at?
    bool is_corrected?
    text verification_status?
    uuid image_id? {
      table = "image"
    }
  
    uuid? user_id? {
      table = "user"
    }
  
    uuid? verified_by_user_id? {
      table = "user"
    }
  
    bool is_external_image?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}