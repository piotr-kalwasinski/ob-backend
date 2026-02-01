table image {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    text file_name?
    text file_path?
    text file_format?
    int width?
    int height?
    int file_size?
    text source?
    text source_uri?
    text source_type?
    enum source_scope? {
      values = ["INTERNAL", "EXTERNAL"]
    }
  
    text external_id? filters=trim
    timestamp uploaded_at?
    bool is_user_generated?
    bool is_moderated?
    text moderation_status?
    text moderation_comments?
    uuid uploaded_by_id? {
      table = "user"
    }
  
    uuid? category_id? {
      table = "category"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}