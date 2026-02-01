table achievement {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    text name?
    text description?
    text icon?
    text achievement_type?
    int threshold_value?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}