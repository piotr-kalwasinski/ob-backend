// Edit team record
query "teams/{id}" verb=PATCH {
  api_group = "Annotations"

  input {
    uuid team_id?
    dblink {
      table = "team"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch team {
      field_name = "id"
      field_value = $input.team_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $team
  }

  response = $team
}