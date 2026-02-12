table sync_log {
  auth = false

  schema {
    uuid id
    timestamp started_at?=now
    timestamp finished_at?
  
    // full | incremental
    text sync_type? filters=trim
  
    int records_fetched?
    int records_inserted?
  
    // success | error | skipped
    text status? filters=trim
  
    text error_message?
    int total_pages_processed?
    int max_external_id?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "started_at", op: "desc"}]}
  ]
}