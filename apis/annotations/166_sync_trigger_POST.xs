// Manual sync trigger — call with sync_type=full or sync_type=incremental.
query sync_trigger verb=POST {
  api_group = "Annotations"
  auth = "user"

  input {
    // Type of sync: full or incremental
    text sync_type?=incremental
  }

  stack {
    conditional {
      if ($input.sync_type == "full") {
        function.run "" as $result
      }
    
      else {
        function.run "" as $result
      }
    }
  }

  response = $result
}