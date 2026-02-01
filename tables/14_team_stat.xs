// Satystyki zespolow 
table team_stat {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    uuid team_id?
    int total_photos_annoted?
    int total_photos_added?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}