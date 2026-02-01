table team {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    text name?
    text description?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}