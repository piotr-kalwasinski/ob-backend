// Zwraca link do zdjecia wraz z rozmiarem
query image verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    int id
    int size?=900
  }

  stack {
    db.get external_image_cache {
      field_name = "external_id"
      field_value = $input.id
      output = [
        "id"
        "external_id"
        "image_url"
        "thumbnail_url"
        "category_id"
        "category_name"
        "external_created_at"
        "synced_at"
        "added_by_bot"
        "context_data"
        "context_source"
        "created_at"
        "file_name"
        "file_path"
        "submission_id"
        "unauthorised"
      ]
    } as $external_image_cache1
  
    var.update $external_image_cache1.image_url {
      value = `$external_image_cache1.image_url | concat:$input.size:"?size="`
    }
  }

  response = $external_image_cache1
}