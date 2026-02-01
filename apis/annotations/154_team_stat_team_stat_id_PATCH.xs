// Edit team_stat record
query "team_stat/{team_stat_id}" verb=PATCH {
  api_group = "Annotations"

  input {
    uuid team_stat_id?
    dblink {
      table = "team_stat"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch team_stat {
      field_name = "id"
      field_value = $input.team_stat_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $team_stat
  }

  response = $team_stat
}