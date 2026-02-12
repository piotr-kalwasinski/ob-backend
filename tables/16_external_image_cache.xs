table external_image_cache {
  auth = false

  schema {
    uuid id
  
    // Image ID from AktywAkcja API (sequential integer, unique)
    int external_id
  
    // Full image URL from AktywAkcja
    text image_url filters=trim
  
    text thumbnail_url? filters=trim
    int category_id?
    text category_name? filters=trim
    timestamp external_created_at?
    timestamp synced_at?=now
    json raw_data?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {
      type : "btree|unique"
      field: [{name: "external_id", op: "asc"}]
    }
    {type: "btree", field: [{name: "category_id", op: "asc"}]}
    {type: "btree", field: [{name: "synced_at", op: "desc"}]}
  ]
}