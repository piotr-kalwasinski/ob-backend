table weekly_goal {
  auth = false

  schema {
    uuid id
    timestamp created_at?=now
    text name?
    text icon?
    int target_photos?
    text motivation_message_start?
    text motivation_message_inprogress?
    text motivation_message_nearcomplete?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}